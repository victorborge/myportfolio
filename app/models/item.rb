class Item < ActiveRecord::Base
  has_many :purchases
  has_many :item_categories
  has_many :categories, through: :item_categories

  attr_accessor :new_category_name

  accepts_nested_attributes_for :categories

  validates :name, :description, :profit_margin, :amount, :ratio_1, :ratio_2, :ratio_3, :ratio_4, :ratio_5, presence: true
  validates :ratio_1, :ratio_2, :ratio_3, :ratio_4, :ratio_5, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, numericality: { greater_than: 0, only_integer: true }
  validates :profit_margin, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_save :create_new_category, if: -> { new_category_name.present? }
  after_save :clean_up_categories

  scope :in_stock, -> { where('stock > 0') }

  def clean_up_categories
    Category.joins("LEFT OUTER JOIN item_categories ON categories.id = item_categories.category_id").where(item_categories: { item_id: nil }).destroy_all
  end

  def create_new_category
    categories.new(name: new_category_name)
  end
end
