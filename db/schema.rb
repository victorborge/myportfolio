# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150831173539) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"

  create_table "credits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "points"
    t.string   "reason"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "credits", ["user_id"], name: "index_credits_on_user_id"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_categories", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "item_categories", ["category_id"], name: "index_item_categories_on_category_id"
  add_index "item_categories", ["item_id"], name: "index_item_categories_on_item_id"

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "amount"
    t.decimal  "ratio_1",       precision: 6, scale: 3
    t.decimal  "ratio_2",       precision: 6, scale: 3
    t.decimal  "ratio_3",       precision: 6, scale: 3
    t.decimal  "ratio_4",       precision: 6, scale: 3
    t.decimal  "ratio_5",       precision: 6, scale: 3
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "profit_margin",                         default: 0
    t.integer  "stock",                                 default: 1
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.string   "type"
    t.integer  "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["admin_id"], name: "index_posts_on_admin_id"

  create_table "purchases", force: :cascade do |t|
    t.integer  "points"
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "claimed_at"
    t.integer  "amount"
    t.integer  "quantity",   default: 1, null: false
    t.string   "paypal_id"
    t.datetime "paid_at"
  end

  add_index "purchases", ["item_id"], name: "index_purchases_on_item_id"
  add_index "purchases", ["user_id"], name: "index_purchases_on_user_id"

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "sponsors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string   "plan_id"
    t.string   "agreement_id"
    t.string   "plan_type"
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
    t.string   "agreement_token"
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.string   "plan_scheme"
  end

  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "user_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "user_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "user_anc_desc_idx", unique: true
  add_index "user_hierarchies", ["descendant_id"], name: "user_desc_idx"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.integer  "recruiter_id"
    t.integer  "leader_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "unconfirmed_email"
    t.integer  "points",                 default: 0
    t.string   "nric"
    t.text     "address"
    t.string   "mobile_number"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["leader_id"], name: "index_users_on_leader_id"
  add_index "users", ["recruiter_id"], name: "index_users_on_recruiter_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
