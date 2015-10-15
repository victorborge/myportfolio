class AddDateTimesToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :activated_at, :datetime
    add_column :subscriptions, :deactivated_at, :datetime
  end
end
