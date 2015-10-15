class AddStockToItems < ActiveRecord::Migration
  def change
    add_column :items, :stock, :integer, default: 1
  end
end
