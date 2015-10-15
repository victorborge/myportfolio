class Post < ActiveRecord::Base
  self.inheritance_column = '_type'

  belongs_to :admin

  validates :title, :content, :admin, presence: true
end
