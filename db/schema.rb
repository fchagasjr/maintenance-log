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

ActiveRecord::Schema[7.0].define(version: 2023_09_10_135556) do
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
    t.bigint "group_id"
    t.index ["assembly_id"], name: "index_entities_on_assembly_id"
    t.index ["group_id"], name: "index_entities_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "description", null: false
  end

  create_table "log_entries", force: :cascade do |t|
    t.text "open_description"
    t.bigint "service_id"
    t.text "close_description"
    t.date "closed_at"
    t.string "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_log_entries_on_entity_id"
    t.index ["service_id"], name: "index_log_entries_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "description", null: false
  end

  add_foreign_key "entities", "assemblies"
  add_foreign_key "entities", "groups"
  add_foreign_key "log_entries", "entities"
  add_foreign_key "log_entries", "services"
end
