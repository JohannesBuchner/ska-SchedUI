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

ActiveRecord::Schema.define(:version => 20110415052517) do

  create_table "bad_dates", :force => true do |t|
    t.integer  "job_id"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "constraints", :force => true do |t|
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_time_preferences", :force => true do |t|
    t.integer  "starttime"
    t.integer  "endtime"
    t.integer  "preferredJob"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "proposal_id"
    t.decimal  "startlst",    :precision => 10, :scale => 0
    t.decimal  "endlst",      :precision => 10, :scale => 0
    t.decimal  "totalhours",  :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposals", :force => true do |t|
    t.string   "name"
    t.decimal  "priority",   :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_contents", :force => true do |t|
    t.integer  "timeslot"
    t.integer  "Schedule_id"
    t.integer  "Job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.boolean  "enabled"
    t.boolean  "favorite"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.string   "catalog"
    t.decimal  "ra",         :precision => 10, :scale => 0
    t.decimal  "dec",        :precision => 10, :scale => 0
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
