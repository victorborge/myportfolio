class Credit < ActiveRecord::Base
  self.inheritance_column = nil

  belongs_to :user

  before_create :add_points
  before_destroy :remove_points

  def add_points
    user.increment!(:points, points)
  end

  def remove_points
    user.decrement!(:points, points)
  end
end
