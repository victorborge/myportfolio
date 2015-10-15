class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.integer :amount
      t.decimal :ratio_1, precision: 6, scale: 3
      t.decimal :ratio_2, precision: 6, scale: 3
      t.decimal :ratio_3, precision: 6, scale: 3
      t.decimal :ratio_4, precision: 6, scale: 3
      t.decimal :ratio_5, precision: 6, scale: 3

      t.timestamps null: false
    end
  end
end
