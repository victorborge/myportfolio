class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :type
      t.belongs_to :admin, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
