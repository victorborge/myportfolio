class Category < ActiveRecord::Base
  has_many :item_categories, dependent: :destroy
  has_many :items, through: :item_categories

  validates :name, presence: true, uniqueness: true
end
