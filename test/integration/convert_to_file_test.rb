require 'test_helper'

require 'mysql2psql'

class ConvertToFileTest < Test::Unit::TestCase
  attr_reader :configfile, :mysql2psql
  def setup
    @configfile = "#{File.dirname(__FILE__)}/../fixtures/config_localmysql_to_file_convert_all.yml"
    @mysql2psql = Mysql2psql.new([configfile])
  end
  def teardown

  end
  def test_convert
    assert_equal 0,mysql2psql.convert
  end

end