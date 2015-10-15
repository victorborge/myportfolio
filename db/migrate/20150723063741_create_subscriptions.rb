class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :plan_id
      t.string :agreement_id
      t.string :plan_type
      t.string :state

      t.timestamps null: false
    end
  end
end
