class ChangePurchasesTable < ActiveRecord::Migration
  def change
    drop_table :purchases, if_exists: true
    create_table :purchases do |t|
      t.integer :points
      t.belongs_to :item, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
