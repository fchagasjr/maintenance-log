# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_20_165453) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assemblies", force: :cascade do |t|
    t.string "description", null: false
    t.string "manufacturer"
    t.string "model"
    t.bigint "log_id"
    t.index ["log_id"], name: "index_assemblies_on_log_id"
  end

  create_table "entities", force: :cascade do |t|
    t.string "description", null: false
    t.bigint "assembly_id", null: false
    t.string "serial"
    t.string "number", null: false
    t.index ["assembly_id"], name: "index_entities_on_assembly_id"
    t.index ["number", "assembly_id"], name: "index_entities_on_number_and_assembly_id", unique: true
  end

  create_table "keys", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.bigint "user_id", null: false
    t.boolean "admin", default: false
    t.boolean "active", default: false
    t.index ["log_id", "user_id"], name: "index_keys_on_log_id_and_user_id", unique: true
    t.index ["log_id"], name: "index_keys_on_log_id"
    t.index ["user_id"], name: "index_keys_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "request_records", force: :cascade do |t|
    t.bigint "request_type_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "entity_id", null: false
    t.index ["created_at"], name: "index_request_records_on_created_at", order: :desc
    t.index ["entity_id"], name: "index_request_records_on_entity_id"
    t.index ["request_type_id"], name: "index_request_records_on_request_type_id"
    t.index ["user_id"], name: "index_request_records_on_user_id"
  end

  create_table "request_types", force: :cascade do |t|
    t.string "description"
  end

  create_table "service_records", force: :cascade do |t|
    t.bigint "request_record_id", null: false
    t.bigint "service_type_id", null: false
    t.text "description"
    t.date "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["request_record_id"], name: "index_service_records_on_request_record_id"
    t.index ["service_type_id"], name: "index_service_records_on_service_type_id"
    t.index ["user_id"], name: "index_service_records_on_user_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "description"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "log_id"
    t.index ["log_id"], name: "index_users_on_log_id"
  end

  add_foreign_key "assemblies", "logs"
  add_foreign_key "entities", "assemblies"
  add_foreign_key "keys", "logs"
  add_foreign_key "keys", "users"
  add_foreign_key "logs", "users"
  add_foreign_key "request_records", "entities"
  add_foreign_key "request_records", "request_types"
  add_foreign_key "request_records", "users"
  add_foreign_key "service_records", "request_records"
  add_foreign_key "service_records", "service_types"
  add_foreign_key "service_records", "users"
  add_foreign_key "users", "logs"
end
