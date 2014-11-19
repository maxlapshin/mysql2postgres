require 'test_helper'

require 'mysql2psql/converter'

class ConverterTest < Test::Unit::TestCase
  class << self
    def startup
      seed_test_database
      @@options = get_test_config_by_label(:localmysql_to_file_convert_nothing)
    end

  end
  def setup
  end

  def teardown
  end

  def options
    @@options
  end

  def test_new_converter
    assert_nothing_raised do
      reader = get_test_reader(options)
      writer = get_test_file_writer(options)
      converter = Mysql2psql::Converter.new(reader, writer, options)
      assert_equal 0, converter.convert
    end
  end
end
