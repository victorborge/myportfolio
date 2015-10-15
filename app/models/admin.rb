class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :users, foreign_key: 'leader_id', inverse_of: :leader
  has_many :posts

  validates :username, length: { is: 2 }, allow_nil: true

  before_save :update_members_usernames

  def username
    self[:username] || '??'
  end

  def update_members_usernames
    users.each(&:update_descendant_usernames)
  end
end
