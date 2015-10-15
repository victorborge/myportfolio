class AddAmountAndQuantityToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :amount, :integer
    add_column :purchases, :quantity, :integer, null: false, default: 1
    Purchase.unscoped.update_all('amount = points')
  end
end
