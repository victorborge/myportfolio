class AddLeaderToUser < ActiveRecord::Migration
  def change
    add_reference :users, :leader, index: true
    add_foreign_key :devise, :admins, column: :leader_id
  end
end
