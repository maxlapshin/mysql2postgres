require 'test_helper'

class MysqlReaderTest < Test::Unit::TestCase

  class << self
    def startup
      seed_test_database
      @@options = get_test_config_by_label(:localmysql_to_file_convert_nothing)
      @@reader=get_test_reader(@@options)
    end
    def shutdown
      delete_files_for_test_config(@@options)
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