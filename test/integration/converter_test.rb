require 'test_helper'

require 'mysql2psql/converter'

class ConverterTest < Test::Unit::TestCase
  attr_accessor :options
  def setup
    seed_test_database
    @options = get_test_config( 'config_localmysql_to_file_convert_nothing.yml' )
  end
  def teardown
    File.delete(options.destfile) if File.exists?(options.destfile)
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