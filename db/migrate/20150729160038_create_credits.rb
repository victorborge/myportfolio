class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :points
      t.string :reason
      t.string :type

      t.timestamps null: false
    end
  end
end
