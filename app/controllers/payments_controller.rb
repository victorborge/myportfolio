require 'paypal-sdk-rest'
class PaymentsController < ApplicationController
  include PayPal::SDK::REST

  before_action :set_subscription, only: [:success, :cancel]
  before_action :authenticate_user!, except: [:success, :cancel]

  layout 'user'

  def create
    plan_type = params.require(:plan_type)
    plan_scheme = params.require(:plan_scheme)
    plan_name = "Reign Global #{plan_type.capitalize} Membership"
    plan_description = "#{plan_scheme.capitalize} subscription for #{plan_name}"
    plan_amount = Setting["plans.#{plan_type}.pricing.#{plan_scheme}"].to_f.round(2).to_s

    plan = find_plan(plan_name, plan_description)
    plan ||= create_plan(plan_name, plan_description, plan_scheme, plan_amount)

    @subscription = current_user.subscriptions.create!({
                                                           state: 'CREATED',
                                                           plan_id: plan.id,
                                                           plan_type: plan_type,
                                                           plan_scheme: plan_scheme
                                                       })

    agreement = Agreement.new({
                                  name: plan_name,
                                  description: plan_description,
                                  start_date: (Time.zone.now + @subscription.recurrence).iso8601, # Time.zone.now.beginning_of_month.next_month.utc.iso8601,
                                  plan: {
                                      id: plan.id
                                  },
                                  payer: {
                                      payment_method: "paypal"
                                  },
                                  override_merchant_preferences: {
                                      setup_fee: {
                                          currency: "SGD",
                                          value: plan_amount # (plan_amount * fraction_of_month_left).round(2).to_s
                                      },
                                      return_url: payment_success_url(@subscription.id),
                                      cancel_url: payment_cancel_url(@subscription.id)
                                  }
                              })

    if agreement.create
      @subscription.update(state: 'PENDING', agreement_token: agreement.token)
      redirect_to agreement.links.select { |link| link.rel == 'approval_url' }.first.href
    else
      logger.fatal "Error creating subscription: #{agreement.error.inspect}"
      flash[:error] = "Cannot create subscription at this moment. Please try again later."
      render :new
    end
  end

  def success
    if params[:token] == @subscription.agreement_token
      agreement = Agreement.new
      agreement.token = @subscription.agreement_token
      agreement.execute

      if agreement.error.blank?
        @subscription.start(agreement.id)
        flash[:success] = "Subscription completed successfully. Your account has been upgraded."
      else
        flash[:error] = "Could not verify PayPal payment. Please contact an admin with this subscription ID: #{@subscription.id} and error: #{agreement.error}"
      end
    else
      flash[:error] = "Could not verify PayPal payment. Please contact an admin with this subscription ID: #{@subscription.id}"
    end
    render :new
  end

  def cancel
    @subscription.update(state: 'CANCELLED')
    flash.alert = "Payment cancelled."
    render :new
  end

  def destroy
    @subscription = current_user.current_subscription.cancel
    if @subscription.errors.empty?
      flash.alert = "Subscription cancelled successfully."
    else
      flash[:error] = @subscription.errors.full_messages.join('. ')
    end
    render :new
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:payment_id])
  end

  def find_plan(name, description)
    Plan.all(status: "ACTIVE").plans.select { |p| p.name == name && p.description == description }.first
  end

  # Create a billing plan if it doesn't exist yet
  def create_plan(name, description, scheme, amount)
    plan = Plan.new({
                        name: name,
                        description: description,
                        type: "INFINITE",
                        payment_definitions: [
                            {
                                name: "#{scheme.capitalize} Payments",
                                type: "REGULAR",
                                frequency: scheme.chomp('ly').upcase,
                                frequency_interval: "1",
                                amount: {
                                    value: amount,
                                    currency: "SGD"
                                },
                                cycles: "0"
                            }
                        ],
                        merchant_preferences: {
                            return_url: payment_success_url(0),
                            cancel_url: payment_cancel_url(0),
                            auto_bill_amount: "YES",
                            initial_fail_amount_action: "CANCEL",
                            max_fail_attempts: "5"
                        }
                    })

    if plan.create && plan.update(path: "/", value: { state: "ACTIVE" }, op: "replace")
      plan
    else
      logger.error plan.error.inspect
      raise Exception.new("Plan failed to create: #{plan.error.inspect}")
    end
  end

  # def fraction_of_month_left
  #   now = Time.zone.now
  #   days_left_in_month = now.end_of_month.to_date - now.to_date
  #   days_left_in_month.to_f / now.end_of_month.day
  # end
end
