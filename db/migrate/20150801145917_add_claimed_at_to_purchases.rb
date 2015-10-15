class AddClaimedAtToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :claimed_at, :datetime
  end
end
