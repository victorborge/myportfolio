class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :recruiter_member_id, :adjust_points
  alias_attribute :member_id, :username

  has_closure_tree parent_column_name: 'recruiter_id', name_column: 'username', order: 'created_at'

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => ":placeholder"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  belongs_to :leader, class_name: "Admin", inverse_of: :users
  has_many :subscriptions, dependent: :delete_all
  has_many :purchases, dependent: :delete_all
  has_many :credits, dependent: :delete_all

  validates :full_name, :email, presence: true
  validates :mobile_number, :nric, :address, presence: true, on: :create
  validates :adjust_points, numericality: { only_integer: true }, allow_blank: true
  validates :nric, nric: true, uniqueness: true, allow_blank: true, allow_nil: true

  before_update :set_points, if: -> { adjust_points.present? }
  after_update :update_descendant_usernames, if: 'leader_id_changed?'
  after_create :set_username
  after_create :send_admin_email

  scope :with_active_subscriptions, -> { joins(:subscriptions).where(subscriptions: { state: 'ACTIVE' }) }
  scope :without_active_subscriptions, -> { includes(:subscriptions).all.select { |u| u.subscriptions.select { |s| s.state == 'ACTIVE' }.empty? } }
  scope :search, -> (search_terms) {
    if search_terms.present?
      query = "%#{search_terms}%"
      search_attrs = %i(username full_name email)
      scopes = search_attrs.map { |attr| arel_table[attr].matches(query) }.reduce(&:or)
      where(scopes)
    end
  }

  def send_admin_email
    AdminMailer.new_user_email(self).deliver_later
  end

  def set_username(new_leader = nil)
    new_leader ||= leader

    leader_username = new_leader ? new_leader.username : '??'

    hashids = Hashids.new('user hashids salt', 2, 'BCDFGHJKMNPQRSTWXYZ')
    update_columns(leader_id: new_leader.try(:id), username: "#{leader_username}-#{hashids.encode(id)}")
  end

  def set_points
    points = self.adjust_points
    self.adjust_points = nil # prevent infinite recursion as credits updates user as well
    self.credits.create!({
                             type: "manual",
                             reason: "Manual adjustment of points",
                             points: points
                         })
  end

  def update_descendant_usernames
    self_and_descendants.each do |u|
      u.set_username(self.leader)
    end
  end

  def points_earned
    credits.sum(:points)
  end

  def current_subscription
    subscriptions.order(activated_at: :desc).find_by(state: 'ACTIVE')
  end

  def current_subscription! # in memory version
    subscriptions.select { |s| s.state == 'ACTIVE'}.sort { |a, b| b.activated_at <=> a.activated_at }.first
  end

  def current_plan
    current_subscription.try(:plan_type)
  end

  def recent_purchases(limit = 5)
    purchases.order(created_at: :desc).includes(:item).limit(limit)
  end

  def monthly_team_sales
    sale_amount = 0
    (1..5).each do |level|
      sale_amount += self.find_all_by_generation(level).
          includes(:purchases).
          where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).
          sum('purchases.points')
    end
    sale_amount
  end

  def breakeven_status
    if credits.sum(:points, type: 'breakeven') < Setting["breakeven_points_for.#{current_plan}.threshold"].to_i
      'before_threshold'
    else
      'after_threshold'
    end
  end

  def rank
    if current_plan
      "#{current_plan.capitalize} Member"
    else
      "Guest"
    end
  end

  def member_id_with_email
    "#{member_id} <#{email}>"
  end
end
