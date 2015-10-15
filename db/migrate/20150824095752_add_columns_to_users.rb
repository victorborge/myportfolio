class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nric, :string
    add_column :users, :address, :text
  end
end
