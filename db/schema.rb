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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120425231132) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commits", :force => true do |t|
    t.string   "number"
    t.text     "description"
    t.integer  "author_id"
    t.datetime "committed_at"
    t.text     "preparation_log"
    t.text     "dev_structure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.boolean  "skipped",         :default => false
    t.string   "build_state",     :default => "pending"
  end

  create_table "commits_parents", :id => false, :force => true do |t|
    t.integer "commit_id"
    t.integer "parent_id"
  end

  create_table "notifications", :force => true do |t|
    t.string   "name"
    t.string   "notification_type"
    t.text     "notification_options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications_projects", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "notification_id"
  end

  create_table "project_instance_commits", :force => true do |t|
    t.integer  "commit_id"
    t.integer  "project_instance_id"
    t.string   "state",               :default => "new"
    t.text     "preparation_log"
    t.text     "data_yaml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_instances", :force => true do |t|
    t.integer  "project_id"
    t.string   "state",             :default => "new"
    t.string   "locked_by"
    t.string   "working_directory"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "name"
    t.datetime "created_at"
  end

  add_index "project_permissions", ["project_id"], :name => "index_project_permissions_on_project_id"
  add_index "project_permissions", ["user_id"], :name => "index_project_permissions_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "project_options"
    t.string   "vcs_type",        :default => "Base"
    t.string   "project_type",    :default => "Base"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",          :default => false
  end

  create_table "test_suite_runs", :force => true do |t|
    t.integer  "test_suite_id"
    t.integer  "commit_id"
    t.integer  "tests_count"
    t.integer  "assertions_count"
    t.integer  "failures_count"
    t.integer  "errors_count"
    t.float    "run_time"
    t.string   "state"
    t.boolean  "exitstatus"
    t.text     "run_log"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_instance_id"
  end

  create_table "test_suites", :force => true do |t|
    t.string   "name"
    t.string   "suite_type"
    t.text     "suite_options"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_unit_runs", :force => true do |t|
    t.integer  "test_unit_id"
    t.integer  "test_suite_run_id"
    t.float    "run_time"
    t.string   "result",            :limit => 1
    t.datetime "created_at"
  end

  create_table "test_units", :force => true do |t|
    t.integer  "test_suite_id"
    t.string   "class_name"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "admin",                  :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
