require 'paypal-sdk-rest'
class Subscription < ActiveRecord::Base
  include PayPal::SDK::REST

  belongs_to :user

  scope :active, -> { where(state: 'ACTIVE') }

  def start(agreement_id = nil)
    return if state == 'ACTIVE'
    Subscription.transaction do
      update(state: 'ACTIVE', activated_at: Time.zone.now, agreement_id: agreement_id)
      user.subscriptions.where(state: 'ACTIVE').where.not(id: self.id).each { |s| s.cancel('changed') }
      award_parent_breakeven_points if plan_scheme == 'yearly'
      delay_for(1.month).disperse_points!
    end
  end

  def disperse_points!
    # TODO: check for IPN cancellation!
    return if state != 'ACTIVE'

    # find credits amount
    points = 0
    (1..5).each do |gen|
      points += user.find_all_by_generation(gen).with_active_subscriptions.count * Setting["plans.#{plan_type}.points.monthly"].to_i
    end

    user.credits.create!({
                             type: "recurring",
                             reason: "Monthly award for Reign Global #{plan_type.capitalize} Membership",
                             points: points
                         })

    # recur job in 1 month
    delay_for(1.month).disperse_points!
  end

  def cancel(reason = "cancelled")

    unless agreement_id
      update_columns(state: 'INACTIVE', deactivated_at: Time.zone.now)
      return
    end

    agreement = Agreement.find(agreement_id)

    if agreement.cancel({ note: "User #{reason} plan." })
      # TODO: make inactive only at end of month?
      update_columns(state: 'INACTIVE', deactivated_at: Time.zone.now)
    else
      logger.warn "Error cancelling agreement #{agreement_id} for subscription #{id}: #{agreement.error.inspect}"
      errors.add(:base, "Error cancelling agreement #{agreement_id} for subscription #{id}: #{agreement.error.inspect}")
    end

    self
  end

  def recurrence
    case plan_scheme
      when 'yearly'
        1.year
      when 'monthly'
        1.month
      else
        raise Exception.new('Invalid plan scheme.')
    end
  end

  # TODO: test
  def award_parent_breakeven_points
    parent = user.parent
    return unless parent.present? && parent.current_plan.present?

    parent.credits.create(type: 'breakeven',
                          reason: "Breakeven points awarded for recruiting user #{user.full_name}",
                          points: Setting["breakeven_points_for.#{parent.current_plan}.who_recruits.#{plan_type}.#{parent.breakeven_status}"])
  end
end
