class AddProfitMarginToItems < ActiveRecord::Migration
  def change
    add_column :items, :profit_margin, :integer, default: 0
  end
end
