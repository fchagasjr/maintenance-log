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

ActiveRecord::Schema[7.0].define(version: 2023_09_13_155728) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assemblies", force: :cascade do |t|
    t.string "description", null: false
    t.string "manufacturer"
    t.string "model"
  end

  create_table "entities", id: :string, force: :cascade do |t|
    t.string "description", null: false
    t.bigint "assembly_id"
    t.index ["assembly_id"], name: "index_entities_on_assembly_id"
  end

  create_table "request_records", force: :cascade do |t|
    t.string "entity_id", null: false
    t.bigint "request_type_id", null: false
    t.text "description"
    t.index ["entity_id"], name: "index_request_records_on_entity_id"
    t.index ["request_type_id"], name: "index_request_records_on_request_type_id"
  end

  create_table "request_types", force: :cascade do |t|
    t.string "description"
  end

  create_table "service_records", force: :cascade do |t|
    t.bigint "request_record_id", null: false
    t.bigint "service_type_id", null: false
    t.text "description"
    t.date "closed_at"
    t.index ["request_record_id"], name: "index_service_records_on_request_record_id"
    t.index ["service_type_id"], name: "index_service_records_on_service_type_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "description"
  end

  add_foreign_key "entities", "assemblies"
  add_foreign_key "request_records", "entities"
  add_foreign_key "request_records", "request_types"
  add_foreign_key "service_records", "request_records"
  add_foreign_key "service_records", "service_types"
end
