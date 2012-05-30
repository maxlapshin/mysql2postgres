require 'test_helper'

require 'mysql2psql/converter'

class ConverterTest < Test::Unit::TestCase

  def setup
    seed_test_database
    @@options=get_test_config_by_label(:localmysql_to_file_convert_nothing)
  end
  def teardown
    delete_files_for_test_config(@@options)
  end
  def options
    @@options
  end
  
  def test_new_converter
    assert_nothing_raised do
      reader=get_test_reader(options)
      writer=get_test_file_writer(options)
      converter=Mysql2psql::Converter.new(reader,writer,options)
      assert_equal 0,converter.convert
    end
  end


end