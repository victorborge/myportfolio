class AddCurrentPlanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_plan, :string
  end
end
