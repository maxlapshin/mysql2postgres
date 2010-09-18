require 'test_helper'

require 'mysql2psql'

class MysqlreaderBaseTest < Test::Unit::TestCase
  attr_accessor :options
  def setup
    begin
      configfile = "#{File.dirname(__FILE__)}/../fixtures/config_localmysql_to_file.yml"
      @options = Mysql2psql::ConfigBase.new( configfile )
    rescue
      raise StandardError.new("Failed to initialize options from #{configfile}. See README for setup requirements.")
    end
  end
  def test_mysql_connection
    assert_nothing_raised do
      reader = Mysql2psql::MysqlReader.new(options)
    end
  end
  def test_mysql_reconnect
    assert_nothing_raised do
      reader = Mysql2psql::MysqlReader.new(options)
      reader.reconnect
    end
  end
end