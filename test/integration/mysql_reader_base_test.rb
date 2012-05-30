require 'test_helper'

require 'mysql2psql/mysql_reader'

class MysqlReaderBaseTest < Test::Unit::TestCase

  def setup
    seed_test_database
    @options = get_test_config_by_label(:localmysql_to_file_convert_nothing)
  end

  def teardown
    delete_files_for_test_config(@options)
  end
  
  def test_mysql_connection
    assert_nothing_raised do
      reader = Mysql2psql::MysqlReader.new(@options)
    end
  end
  def test_mysql_reconnect
    assert_nothing_raised do
      reader = Mysql2psql::MysqlReader.new(@options)
      reader.reconnect
    end
  end
  def test_mysql_connection_without_port
    assert_nothing_raised do
      @options.mysqlport = ""
      @options.mysqlsocket = ""
      reader = Mysql2psql::MysqlReader.new(@options)
    end
  end
end