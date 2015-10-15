class Purchase < ActiveRecord::Base
  attr_accessor :using_cod

  belongs_to :user
  belongs_to :item

  validates :user, :item, :points, :amount, :quantity, presence: true
  validates :amount, :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :points, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :ensure_sufficient_points, on: :create

  before_validation :set_amount_and_points

  scope :search, -> (search_terms) {
    if search_terms.present?
      query = "%#{search_terms}%"
      search_attrs = {
          users: %i(username full_name email),
          items: %i(name)
      }
      scopes = search_attrs.map { |table_name, attrs|
        table = Arel::Table.new(table_name)
        attrs.map { |attr| table[attr].matches(query) }.reduce(&:or)
      }.reduce(&:or)
      where(scopes)
    end
  }

  # query = "%#{search_terms}%"
  # search_attrs = %i(username full_name email)
  # users = Arel::Table.new(:users)
  # scopes = search_attrs.map { |attr| users[attr].matches(query) }.reduce { |scopes, scope| scopes.or(scope) }
  # where(scopes)

  def ensure_sufficient_points
    if user.points < points
      errors.add(:user, "has insufficient points")
    end
  end

  def set_amount_and_points
    self.amount = item.amount * self.quantity
    self.points ||= 0
    self.points = amount if points > amount # automatically normalize points if too many used
  end

  def complete
    # FIXME: this does nothing? (`update` does not raise); return validation and don't send email on failure!
    self.transaction do
      user.decrement!(:points, points)
      update(paid_at: Time.zone.now) unless using_cod
    end

    send_emails
  end

  def expire
    self.destroy if paid_at.nil?
  end

  def award_parent_points(level = 1, previous = user)
    parent = previous.parent

    return if level == 6 || parent.nil?

    ratio = item.send("ratio_#{level}").to_f

    parent.credits.create!({
                               type: "purchase",
                               reason: "Purchase of #{item.name} by #{user.member_id}",
                               points: item.profit_margin * (ratio / 100)
                           })


    award_parent_points(level + 1, parent)
  end

  def payment_amount
    amount - points
  end

  def using_cod
    @using_cod == 'true'
  end

  private

  def send_emails
    UserMailer.purchase_receipt_email(self).deliver_later
    AdminMailer.new_purchase_email(self).deliver_later
  end
end
