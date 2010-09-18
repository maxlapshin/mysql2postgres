require 'test_helper'

require 'mysql2psql'

class MysqlreaderTest < Test::Unit::TestCase
  attr_accessor :reader
  class << self
    def startup
      seed_test_database
      @@reader=get_test_reader(get_test_config('config_localmysql_to_file_convert_nothing.yml'))
    end
    def shutdown
    end
  end
  def setup
  end
  def teardown
  end
  def reader
    @@reader
  end
  
  def test_db_connection
    assert_nothing_raised do
      reader.mysql.ping
    end
  end
  def test_tables_collection
    values = reader.tables.select{|t| t.name == 'numeric_types_basics'}
    assert_true values.length==1
    assert_equal 'numeric_types_basics', values[0].name
  end
  def test_paginated_read
    expected_rows=3
    page_size=2
    expected_pages=(1.0 * expected_rows / page_size).ceil
    
    row_count=my_row_count=0
    table = reader.tables.select{|t| t.name == 'numeric_types_basics'}[0]
    reader.paginated_read(table, page_size) do |row,counter|
      row_count=counter
      my_row_count+=1
    end
    assert_equal expected_rows, row_count
    assert_equal expected_rows, my_row_count
  end
end