class RemoveCurrentPlanFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :current_plan
  end
end
