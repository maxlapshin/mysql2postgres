require 'test_helper'

require 'mysql2psql'

class MysqlreaderBaseTest < Test::Unit::TestCase
  attr_accessor :options
  def setup
    @options = get_test_config( 'config_localmysql_to_file_convert_nothing.yml' )
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