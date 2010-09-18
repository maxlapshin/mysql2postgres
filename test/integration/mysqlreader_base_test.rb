require 'test_helper'

require 'mysql2psql'

class MysqlreaderBaseTest < Test::Unit::TestCase
  attr_accessor :options
  def setup
    @options = Mysql2psql::ConfigBase.new( "#{File.dirname(__FILE__)}/../fixtures/config_localmysql_to_file.yml" )
  end
  def teardown
    
  end
  def test_db_connection
    assert_nothing_raised do
      reader = Mysql2psql::MysqlReader.new(
        options.mysqlhostname('localhost'), options.mysqlusername, options.mysqlpassword, 
        options.mysqldatabase, options.mysqlport, options.mysqlsocket )
    end
  end
end