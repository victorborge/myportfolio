class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
