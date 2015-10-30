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

ActiveRecord::Schema.define(version: 20151030162360) do

  create_table "background_sources", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "jurisdiction_id", limit: 4
  end

  add_index "background_sources", ["jurisdiction_id"], name: "index_background_sources_on_jurisdiction_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "districts", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "internal_id",          limit: 255
    t.string   "district_type",        limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "ocd_object_id",        limit: 4
    t.integer  "jurisdiction_id",      limit: 4
    t.integer  "background_source_id", limit: 4
  end

  add_index "districts", ["background_source_id"], name: "index_districts_on_background_source_id", using: :btree
  add_index "districts", ["jurisdiction_id"], name: "index_districts_on_jurisdiction_id", using: :btree
  add_index "districts", ["ocd_object_id"], name: "index_districts_on_ocd_object_id", using: :btree

  create_table "districts_reporting_units", id: false, force: :cascade do |t|
    t.integer "reporting_unit_id", limit: 4, null: false
    t.integer "district_id",       limit: 4, null: false
  end

  add_index "districts_reporting_units", ["district_id"], name: "index_districts_reporting_units_on_district_id", using: :btree
  add_index "districts_reporting_units", ["reporting_unit_id"], name: "index_districts_reporting_units_on_reporting_unit_id", using: :btree

  create_table "election_report_uploads", force: :cascade do |t|
    t.integer  "election_report_id",   limit: 4
    t.integer  "jurisdiction_id",      limit: 4
    t.string   "file_name",            limit: 255
    t.string   "source_type",          limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "background_source_id", limit: 4
  end

  create_table "election_result_uploads", force: :cascade do |t|
    t.integer  "election_report_id", limit: 4
    t.integer  "row_count",          limit: 4
    t.integer  "rows_processed",     limit: 4
    t.string   "file_name",          limit: 255
    t.string   "source_type",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "jurisdictions", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "abbreviation", limit: 255
    t.text     "contact_info", limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "state_id",     limit: 4
  end

  add_index "jurisdictions", ["state_id"], name: "index_jurisdictions_on_state_id", using: :btree

  create_table "ocd_objects", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "unit_type",     limit: 255
    t.string   "district_type", limit: 255
    t.string   "ocd_id",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "ocd_object_id", limit: 4
  end

  add_index "ocd_objects", ["ocd_id"], name: "index_ocd_objects_on_ocd_id", using: :btree
  add_index "ocd_objects", ["ocd_object_id"], name: "index_ocd_objects_on_ocd_object_id", using: :btree

  create_table "reporting_units", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "internal_id",          limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "ocd_object_id",        limit: 4
    t.integer  "jurisdiction_id",      limit: 4
    t.integer  "background_source_id", limit: 4
  end

  add_index "reporting_units", ["background_source_id"], name: "index_reporting_units_on_background_source_id", using: :btree
  add_index "reporting_units", ["jurisdiction_id"], name: "index_reporting_units_on_jurisdiction_id", using: :btree
  add_index "reporting_units", ["ocd_object_id"], name: "index_reporting_units_on_ocd_object_id", using: :btree

  create_table "shape_sources", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.text     "contact_info",         limit: 65535
    t.text     "source_data",          limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "background_source_id", limit: 4
  end

  add_index "shape_sources", ["background_source_id"], name: "index_shape_sources_on_background_source_id", using: :btree

  create_table "shapes", force: :cascade do |t|
    t.string   "internal_id",     limit: 255
    t.binary   "shape_data",      limit: 16777215
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "ocd_object_id",   limit: 4
    t.integer  "shape_source_id", limit: 4
    t.string   "shape_type",      limit: 255
  end

  add_index "shapes", ["ocd_object_id"], name: "index_shapes_on_ocd_object_id", using: :btree
  add_index "shapes", ["shape_source_id"], name: "index_shapes_on_shape_source_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "abbreviation", limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "vedastore_ballot_selection_candidate_id_refs", force: :cascade do |t|
    t.integer "ballot_selection_id", limit: 4
    t.string  "candidate_id_ref",    limit: 255
  end

  add_index "vedastore_ballot_selection_candidate_id_refs", ["ballot_selection_id", "candidate_id_ref"], name: "vedastore_candidate_selection_candidates", using: :btree

  create_table "vedastore_ballot_selection_endorsement_party_id_refs", force: :cascade do |t|
    t.integer "ballot_selection_id", limit: 4
    t.string  "party_id_ref",        limit: 255
  end

  add_index "vedastore_ballot_selection_endorsement_party_id_refs", ["ballot_selection_id", "party_id_ref"], name: "vedastore_candidate_selection_parties", using: :btree

  create_table "vedastore_ballot_selection_party_id_refs", force: :cascade do |t|
    t.integer "ballot_selection_id", limit: 4
    t.string  "party_id_ref",        limit: 255
  end

  add_index "vedastore_ballot_selection_party_id_refs", ["ballot_selection_id", "party_id_ref"], name: "vedastore_party_selection_parties", using: :btree

  create_table "vedastore_ballot_selections", force: :cascade do |t|
    t.integer  "contest_id",     limit: 4
    t.integer  "sequence_order", limit: 4
    t.string   "type",           limit: 255
    t.string   "object_id",      limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "selection_id",   limit: 4
    t.boolean  "is_write_in",    limit: 1
  end

  add_index "vedastore_ballot_selections", ["contest_id"], name: "vedastore_ballot_selection_contest", using: :btree
  add_index "vedastore_ballot_selections", ["object_id"], name: "vedastore_ballot_selection_object_id", using: :btree
  add_index "vedastore_ballot_selections", ["selection_id"], name: "vedastore_ballot_measure_selections", using: :btree

  create_table "vedastore_ballot_style_gp_unit_id_refs", force: :cascade do |t|
    t.integer "ballot_style_id", limit: 4
    t.string  "gp_unit_id_ref",  limit: 255
  end

  add_index "vedastore_ballot_style_gp_unit_id_refs", ["gp_unit_id_ref", "ballot_style_id"], name: "vedastore_ballot_style_gp_units", using: :btree

  create_table "vedastore_ballot_style_party_id_refs", force: :cascade do |t|
    t.integer "ballot_style_id", limit: 4
    t.string  "party_id_ref",    limit: 255
  end

  add_index "vedastore_ballot_style_party_id_refs", ["party_id_ref", "ballot_style_id"], name: "vedastore_ballot_style_parties", using: :btree

  create_table "vedastore_ballot_styles", force: :cascade do |t|
    t.integer  "election_id", limit: 4
    t.string   "image_uri",   limit: 255
    t.string   "object_id",   limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "vedastore_ballot_styles", ["election_id"], name: "vedastore_ballot_style_election", using: :btree

  create_table "vedastore_candidates", force: :cascade do |t|
    t.integer  "election_id",          limit: 4
    t.integer  "ballot_name_id",       limit: 4
    t.string   "party_identifier",     limit: 255
    t.string   "person_identifier",    limit: 255
    t.string   "object_id",            limit: 255
    t.date     "file_date"
    t.boolean  "is_incumbent",         limit: 1
    t.boolean  "is_top_ticket",        limit: 1
    t.string   "post_election_status", limit: 255
    t.string   "pre_election_status",  limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "vedastore_candidates", ["ballot_name_id"], name: "vedastore_candidate_ballot_name", using: :btree
  add_index "vedastore_candidates", ["election_id"], name: "vedastore_candidate_election", using: :btree
  add_index "vedastore_candidates", ["object_id"], name: "vedastore_candidate_object_id", using: :btree

  create_table "vedastore_contact_informations", force: :cascade do |t|
    t.integer  "contactable_id",   limit: 4
    t.string   "contactable_type", limit: 255
    t.text     "address_line",     limit: 65535
    t.text     "email",            limit: 65535
    t.text     "fax",              limit: 65535
    t.string   "name",             limit: 255
    t.text     "phone",            limit: 65535
    t.text     "uri",              limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "vedastore_contact_informations", ["contactable_id", "contactable_type"], name: "vedastore_contactable", using: :btree

  create_table "vedastore_contest_office_id_refs", force: :cascade do |t|
    t.integer "contest_id",    limit: 4
    t.string  "office_id_ref", limit: 255
  end

  add_index "vedastore_contest_office_id_refs", ["contest_id", "office_id_ref"], name: "vedastore_contest_offices", using: :btree

  create_table "vedastore_contests", force: :cascade do |t|
    t.string   "type",                          limit: 255
    t.integer  "election_id",                   limit: 4
    t.integer  "ballot_sub_title_id",           limit: 4
    t.integer  "ballot_title_id",               limit: 4
    t.string   "electoral_district_identifier", limit: 255
    t.string   "name",                          limit: 255
    t.string   "object_id",                     limit: 255
    t.string   "abbreviation",                  limit: 255
    t.boolean  "has_rotation",                  limit: 1
    t.string   "other_vote_variation",          limit: 255
    t.integer  "sequence_order",                limit: 4
    t.integer  "sub_units_reported",            limit: 4
    t.integer  "total_sub_units",               limit: 4
    t.string   "vote_variation",                limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "con_statement_id",              limit: 4
    t.integer  "effect_of_abstain_id",          limit: 4
    t.integer  "full_text_id",                  limit: 4
    t.integer  "passage_threshold_id",          limit: 4
    t.integer  "pro_statement_id",              limit: 4
    t.integer  "summary_text_id",               limit: 4
    t.string   "other_type",                    limit: 255
    t.string   "ballot_measure_type",           limit: 255
    t.string   "primary_party_identifier",      limit: 255
    t.integer  "number_elected",                limit: 4
    t.integer  "votes_allowed",                 limit: 4
    t.string   "candidate_identifier",          limit: 255
    t.string   "office_identifier",             limit: 255
  end

  add_index "vedastore_contests", ["ballot_sub_title_id"], name: "vedastore_contest_ballot_sub_title", using: :btree
  add_index "vedastore_contests", ["ballot_title_id"], name: "vedastore_contest_ballot_title", using: :btree
  add_index "vedastore_contests", ["candidate_identifier"], name: "vedastore_ret_con_candidate", using: :btree
  add_index "vedastore_contests", ["con_statement_id"], name: "vedastore_ballot_measure_con_statement", using: :btree
  add_index "vedastore_contests", ["effect_of_abstain_id"], name: "vedastore_ballot_measure_effect_of_abstain", using: :btree
  add_index "vedastore_contests", ["election_id"], name: "vedastore_contest_election", using: :btree
  add_index "vedastore_contests", ["full_text_id"], name: "vedastore_ballot_measure_full_text", using: :btree
  add_index "vedastore_contests", ["object_id"], name: "vedastore_contest_object_id", using: :btree
  add_index "vedastore_contests", ["office_identifier"], name: "vedastore_ret_con_office", using: :btree
  add_index "vedastore_contests", ["passage_threshold_id"], name: "vedastore_ballot_measure_passage_threshold", using: :btree
  add_index "vedastore_contests", ["primary_party_identifier"], name: "vedastore_can_con_primary_party", using: :btree
  add_index "vedastore_contests", ["pro_statement_id"], name: "vedastore_ballot_measure_pro_statement", using: :btree
  add_index "vedastore_contests", ["summary_text_id"], name: "vedastore_ballot_measure_summary_text", using: :btree

  create_table "vedastore_count_statuses", force: :cascade do |t|
    t.integer  "count_statusable_id",   limit: 4
    t.string   "count_statusable_type", limit: 255
    t.string   "other_type",            limit: 255
    t.string   "status",                limit: 255
    t.string   "count_item_type",       limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "vedastore_count_statuses", ["count_statusable_id", "count_statusable_type"], name: "vedastore_count_statusable", using: :btree

  create_table "vedastore_counts", force: :cascade do |t|
    t.string   "type",                      limit: 255
    t.integer  "countable_id",              limit: 4
    t.string   "countable_type",            limit: 255
    t.integer  "device_id",                 limit: 4
    t.string   "gp_unit_identifier",        limit: 255
    t.boolean  "is_suppressed_for_privacy", limit: 1
    t.string   "other_type",                limit: 255
    t.string   "count_item_type",           limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "ballots_cast",              limit: 4
    t.integer  "ballots_outstanding",       limit: 4
    t.integer  "ballots_rejected",          limit: 4
    t.integer  "overvotes",                 limit: 4
    t.integer  "undervotes",                limit: 4
    t.integer  "write_ins",                 limit: 4
    t.integer  "summary_countable_id",      limit: 4
    t.string   "summary_countable_type",    limit: 255
    t.float    "count",                     limit: 24
  end

  add_index "vedastore_counts", ["countable_id", "countable_type"], name: "vedastore_countable", using: :btree
  add_index "vedastore_counts", ["device_id"], name: "vedastore_counts_device", using: :btree
  add_index "vedastore_counts", ["gp_unit_identifier"], name: "vedastore_counts_gp_unit", using: :btree
  add_index "vedastore_counts", ["summary_countable_id", "summary_countable_type"], name: "vedastore_counts_summary_countable", using: :btree
  add_index "vedastore_counts", ["type"], name: "vedastore_counts_type", using: :btree

  create_table "vedastore_devices", force: :cascade do |t|
    t.string   "manufacturer", limit: 255
    t.string   "model",        limit: 255
    t.string   "device_type",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "vedastore_election_administration_official_id_refs", force: :cascade do |t|
    t.integer "election_administration_id", limit: 4
    t.string  "election_official_id_ref",   limit: 255
  end

  add_index "vedastore_election_administration_official_id_refs", ["election_administration_id", "election_official_id_ref"], name: "vedastore_election_admin_official_ref", using: :btree

  create_table "vedastore_election_administrations", force: :cascade do |t|
    t.integer  "contact_information_id", limit: 4
    t.string   "name",                   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "vedastore_election_administrations", ["contact_information_id"], name: "vedastore_election_admin_contact_information", using: :btree

  create_table "vedastore_election_reports", force: :cascade do |t|
    t.integer  "election_id",                   limit: 4
    t.text     "notes",                         limit: 65535
    t.string   "format",                        limit: 255
    t.datetime "generated_date"
    t.string   "issuer",                        limit: 255
    t.string   "issuer_abbreviation",           limit: 255
    t.boolean  "is_test",                       limit: 1
    t.integer  "sequence_start",                limit: 4
    t.integer  "sequence_end",                  limit: 4
    t.string   "status",                        limit: 255
    t.string   "test_type",                     limit: 255
    t.string   "vendor_application_identifier", limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "vedastore_election_reports", ["election_id"], name: "vedastore_election_reports_election", using: :btree

  create_table "vedastore_elections", force: :cascade do |t|
    t.integer  "contact_information_id",    limit: 4
    t.string   "election_scope_identifier", limit: 255
    t.integer  "name_id",                   limit: 4
    t.date     "start_date"
    t.date     "end_date"
    t.string   "election_type",             limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "vedastore_elections", ["contact_information_id"], name: "vedastore_election_contact_information", using: :btree
  add_index "vedastore_elections", ["election_scope_identifier"], name: "vedastore_elections_gp_scope", using: :btree
  add_index "vedastore_elections", ["name_id"], name: "vedastore_elections_name", using: :btree

  create_table "vedastore_external_identifier_collections", force: :cascade do |t|
    t.string   "identifiable_type", limit: 255
    t.integer  "identifiable_id",   limit: 4
    t.string   "label",             limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "vedastore_external_identifier_collections", ["identifiable_type", "identifiable_id"], name: "vedastore_identifiable", using: :btree

  create_table "vedastore_external_identifiers", force: :cascade do |t|
    t.integer  "external_identifier_collection_id", limit: 4
    t.string   "identifier_type",                   limit: 255
    t.string   "other_type",                        limit: 255
    t.string   "value",                             limit: 255
    t.string   "label",                             limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "vedastore_gp_unit_authority_id_refs", force: :cascade do |t|
    t.integer "gp_unit_id",       limit: 4
    t.string  "authority_id_ref", limit: 255
  end

  add_index "vedastore_gp_unit_authority_id_refs", ["gp_unit_id", "authority_id_ref"], name: "vedastore_gp_unit_authorities", using: :btree

  create_table "vedastore_gp_unit_composing_gp_unit_id_refs", force: :cascade do |t|
    t.integer "gp_unit_id",               limit: 4
    t.string  "composing_gp_unit_id_ref", limit: 255
  end

  add_index "vedastore_gp_unit_composing_gp_unit_id_refs", ["gp_unit_id", "composing_gp_unit_id_ref"], name: "vedastore_gp_unit_composing_units", using: :btree

  create_table "vedastore_gp_units", force: :cascade do |t|
    t.string   "type",                       limit: 255
    t.integer  "election_report_id",         limit: 4
    t.string   "object_id",                  limit: 255
    t.string   "name",                       limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "device_id",                  limit: 4
    t.string   "serial_number",              limit: 255
    t.integer  "contact_information_id",     limit: 4
    t.integer  "election_administration_id", limit: 4
    t.text     "count_statuses",             limit: 65535
    t.integer  "spatial_dimension_id",       limit: 4
    t.boolean  "is_districted",              limit: 1
    t.boolean  "is_mail_only",               limit: 1
    t.string   "number",                     limit: 255
    t.string   "other_type",                 limit: 255
    t.integer  "sub_units_reported",         limit: 4
    t.integer  "total_sub_units",            limit: 4
    t.string   "reporting_unit_type",        limit: 255
    t.integer  "voters_participated",        limit: 4
    t.integer  "voters_registered",          limit: 4
  end

  add_index "vedastore_gp_units", ["contact_information_id"], name: "vedastore_gp_unit_contact_info", using: :btree
  add_index "vedastore_gp_units", ["election_report_id"], name: "vscc_gp_unit_election_report", using: :btree
  add_index "vedastore_gp_units", ["object_id"], name: "vedastore_gp_unit_object_id", using: :btree
  add_index "vedastore_gp_units", ["spatial_dimension_id"], name: "vedastore_gp_unit_spatial_dimension", using: :btree
  add_index "vedastore_gp_units", ["type"], name: "vedastore_gp_unit_type", using: :btree

  create_table "vedastore_hours", force: :cascade do |t|
    t.integer  "hourable_id",   limit: 4
    t.string   "hourable_type", limit: 255
    t.string   "day",           limit: 255
    t.datetime "end_time"
    t.datetime "start_time"
    t.string   "label",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "vedastore_hours", ["hourable_id", "hourable_type"], name: "vedastore_hourable", using: :btree

  create_table "vedastore_internationalized_texts", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "vedastore_language_strings", force: :cascade do |t|
    t.integer  "internationalized_text_id", limit: 4
    t.string   "language",                  limit: 255
    t.text     "text",                      limit: 65535
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "vedastore_language_strings", ["internationalized_text_id"], name: "vedastore_language_string_internationalized_text", using: :btree

  create_table "vedastore_office_group_office_ids", force: :cascade do |t|
    t.integer "office_id",     limit: 4
    t.string  "office_id_ref", limit: 255
  end

  add_index "vedastore_office_group_office_ids", ["office_id", "office_id_ref"], name: "vedastore_office_group_office_refs", using: :btree

  create_table "vedastore_office_groups", force: :cascade do |t|
    t.integer  "office_groupable_id",   limit: 4
    t.string   "office_groupable_type", limit: 255
    t.string   "name",                  limit: 255
    t.string   "label",                 limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "vedastore_office_groups", ["office_groupable_id", "office_groupable_type"], name: "vedastore_office_groupable", using: :btree

  create_table "vedastore_office_office_holder_id_refs", force: :cascade do |t|
    t.integer "office_id",            limit: 4
    t.string  "office_holder_id_ref", limit: 255
  end

  add_index "vedastore_office_office_holder_id_refs", ["office_id", "office_holder_id_ref"], name: "vedastore_office_office_holder_ref", using: :btree

  create_table "vedastore_offices", force: :cascade do |t|
    t.integer  "office_group_id",               limit: 4
    t.integer  "election_report_id",            limit: 4
    t.integer  "contact_information_id",        limit: 4
    t.string   "electoral_district_identifier", limit: 255
    t.integer  "name_id",                       limit: 4
    t.integer  "term_id",                       limit: 4
    t.string   "object_id",                     limit: 255
    t.datetime "filing_deadline"
    t.boolean  "is_partisan",                   limit: 1
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "vedastore_offices", ["contact_information_id"], name: "vedastore_office_contact_information", using: :btree
  add_index "vedastore_offices", ["election_report_id"], name: "vedastore_office_election_report", using: :btree
  add_index "vedastore_offices", ["electoral_district_identifier"], name: "vedastore_office_jurisdiction_scope", using: :btree
  add_index "vedastore_offices", ["name_id"], name: "vedastore_office_name", using: :btree
  add_index "vedastore_offices", ["object_id"], name: "vedastore_office_object_id", using: :btree
  add_index "vedastore_offices", ["office_group_id"], name: "vedastore_office_office_group", using: :btree
  add_index "vedastore_offices", ["term_id"], name: "vedastore_office_term", using: :btree

  create_table "vedastore_ordered_contest_ballot_selection_id_refs", force: :cascade do |t|
    t.integer "ordered_contest_id",      limit: 4
    t.string  "ballot_selection_id_ref", limit: 255
  end

  add_index "vedastore_ordered_contest_ballot_selection_id_refs", ["ordered_contest_id", "ballot_selection_id_ref"], name: "vedastore_ordered_contest_ballot_selection_ref", using: :btree

  create_table "vedastore_ordered_contests", force: :cascade do |t|
    t.integer  "ballot_style_id",    limit: 4
    t.string   "contest_identifier", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "vedastore_ordered_contests", ["ballot_style_id"], name: "vscc_ordered_contest_ballot_style", using: :btree
  add_index "vedastore_ordered_contests", ["contest_identifier"], name: "vedastore_ordered_contest_identifier", using: :btree

  create_table "vedastore_parties", force: :cascade do |t|
    t.integer  "election_report_id", limit: 4
    t.integer  "name_id",            limit: 4
    t.string   "object_id",          limit: 255
    t.string   "abbreviation",       limit: 255
    t.string   "color",              limit: 255
    t.string   "logo_uri",           limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "contest_identifier", limit: 255
  end

  add_index "vedastore_parties", ["contest_identifier"], name: "vedastore_party_contest", using: :btree
  add_index "vedastore_parties", ["election_report_id"], name: "vedastore_party_election_report", using: :btree
  add_index "vedastore_parties", ["name_id"], name: "vedastore_party_name", using: :btree
  add_index "vedastore_parties", ["object_id"], name: "vedastore_party_object_id", using: :btree

  create_table "vedastore_party_contest_id_refs", force: :cascade do |t|
    t.integer "party_id",       limit: 4
    t.string  "contest_id_ref", limit: 255
  end

  add_index "vedastore_party_contest_id_refs", ["party_id", "contest_id_ref"], name: "vedastore_party_contest_id_ref", using: :btree

  create_table "vedastore_party_party_id_refs", force: :cascade do |t|
    t.integer "party_id",     limit: 4
    t.string  "party_id_ref", limit: 255
  end

  add_index "vedastore_party_party_id_refs", ["party_id", "party_id_ref"], name: "vedastore_party_party_id_ref", using: :btree

  create_table "vedastore_party_registrations", force: :cascade do |t|
    t.string   "type",                        limit: 255
    t.integer  "election_report_id",          limit: 4
    t.string   "party_identifier",            limit: 255
    t.integer  "count",                       limit: 4
    t.integer  "party_registrationable_id",   limit: 4
    t.string   "party_registrationable_type", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "vedastore_party_registrations", ["election_report_id"], name: "vedastore_party_registration_election_report", using: :btree
  add_index "vedastore_party_registrations", ["party_identifier"], name: "vedastore_party_reg_identifier", using: :btree
  add_index "vedastore_party_registrations", ["party_registrationable_id", "party_registrationable_type"], name: "vedastore_party_registrationable", using: :btree

  create_table "vedastore_people", force: :cascade do |t|
    t.integer  "election_report_id", limit: 4
    t.string   "first_name",         limit: 255
    t.integer  "full_name_id",       limit: 4
    t.string   "last_name",          limit: 255
    t.text     "middle_names",       limit: 65535
    t.string   "nickname",           limit: 255
    t.string   "party_identifier",   limit: 255
    t.string   "prefix",             limit: 255
    t.integer  "profession_id",      limit: 4
    t.string   "sufix",              limit: 255
    t.integer  "title_id",           limit: 4
    t.string   "object_id",          limit: 255
    t.date     "date_of_birth"
    t.string   "gender",             limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "vedastore_people", ["election_report_id"], name: "vedastore_person_election_report", using: :btree
  add_index "vedastore_people", ["full_name_id"], name: "vedastore_person_full_name", using: :btree
  add_index "vedastore_people", ["object_id"], name: "vedastore_person_object_id", using: :btree
  add_index "vedastore_people", ["profession_id"], name: "vedastore_person_profession", using: :btree
  add_index "vedastore_people", ["title_id"], name: "vedastore_perspon_title", using: :btree

  create_table "vedastore_rails_vssc_annotated_strings", force: :cascade do |t|
    t.text     "value",      limit: 65535
    t.string   "annotation", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "vedastore_schedules", force: :cascade do |t|
    t.integer  "schedulable_id",         limit: 4
    t.string   "schedulable_type",       limit: 255
    t.date     "end_date"
    t.date     "start_date"
    t.boolean  "is_only_by_appointment", limit: 1
    t.boolean  "is_or_by_appointment",   limit: 1
    t.boolean  "is_subject_to_change",   limit: 1
    t.string   "label",                  limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "vedastore_schedules", ["schedulable_id", "schedulable_type"], name: "vedastore_schedulable", using: :btree

  create_table "vedastore_spatial_dimensions", force: :cascade do |t|
    t.integer  "spatial_extent_id", limit: 4
    t.string   "map_uri",           limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "vedastore_spatial_dimensions", ["spatial_extent_id"], name: "vedastore_spatial_dimension_spatial_extent", using: :btree

  create_table "vedastore_spatial_extents", force: :cascade do |t|
    t.text     "coordinates", limit: 65535
    t.string   "format",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "vedastore_terms", force: :cascade do |t|
    t.date     "end_date"
    t.date     "start_date"
    t.string   "office_term_type", limit: 255
    t.string   "label",            limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

end
