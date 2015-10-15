class AddRecruiterToUser < ActiveRecord::Migration
  def change
    add_reference :users, :recruiter, index: true
    add_foreign_key :devise, :devise, column: :recruiter_id
  end
end
