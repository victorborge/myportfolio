class AddPlanSchemeToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :plan_scheme, :string
  end
end
