class AddPaypalColumnsToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :paypal_id, :string
    add_column :purchases, :paid_at, :datetime
    Purchase.unscoped.update_all('paid_at = created_at')
  end
end
