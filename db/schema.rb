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

ActiveRecord::Schema.define(:version => 20110828135611) do

  create_table "eq_quotes", :force => true do |t|
    t.integer "stock_id"
    t.decimal "open",            :precision => 8,  :scale => 2
    t.decimal "high",            :precision => 8,  :scale => 2
    t.decimal "low",             :precision => 8,  :scale => 2
    t.decimal "close",           :precision => 8,  :scale => 2
    t.decimal "previous_close",  :precision => 8,  :scale => 2
    t.decimal "mov_avg_10d",     :precision => 8,  :scale => 2
    t.decimal "mov_avg_50d",     :precision => 8,  :scale => 2
    t.decimal "mov_avg_200d",    :precision => 8,  :scale => 2
    t.decimal "traded_quantity", :precision => 12, :scale => 2
    t.date    "date"
  end

  add_index "eq_quotes", ["date"], :name => "index_eq_quotes_on_date"
  add_index "eq_quotes", ["stock_id", "date"], :name => "index_eq_quotes_on_stock_id_and_date"
  add_index "eq_quotes", ["stock_id"], :name => "index_eq_quotes_on_stock_id"

  create_table "fo_quotes", :force => true do |t|
    t.integer "stock_id"
    t.decimal "open",                                 :precision => 8,  :scale => 2
    t.decimal "high",                                 :precision => 8,  :scale => 2
    t.decimal "low",                                  :precision => 8,  :scale => 2
    t.decimal "close",                                :precision => 8,  :scale => 2
    t.decimal "strike_price",                         :precision => 8,  :scale => 2
    t.decimal "traded_quantity",                      :precision => 14, :scale => 2
    t.decimal "open_interest",                        :precision => 14, :scale => 2
    t.decimal "change_in_open_interest",              :precision => 10, :scale => 2
    t.date    "date"
    t.date    "expiry_date"
    t.string  "fo_type",                 :limit => 2
    t.string  "expiry_series",           :limit => 7
  end

  add_index "fo_quotes", ["stock_id"], :name => "index_fo_quotes_on_stock_id"

  create_table "stocks", :force => true do |t|
    t.string "symbol"
    t.string "series"
    t.date   "date"
  end

  add_index "stocks", ["symbol"], :name => "index_stocks_on_symbol"

  add_foreign_key "eq_quotes", "stocks", :name => "eq_quotes_stock_id_fk"

end
