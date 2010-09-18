require 'test_helper'

require 'mysql2psql'

class ConvertToDbTest < Test::Unit::TestCase
  class << self
    def startup
      configfile = "#{File.dirname(__FILE__)}/../fixtures/config_localmysql_to_db_convert_all.yml"
      seed_test_database
      @@mysql2psql = Mysql2psql.new([configfile])
      @@mysql2psql.convert
      @@mysql2psql.writer.open
    end
    def shutdown
      @@mysql2psql.writer.close
    end
  end
  def setup
  end
  def teardown
  end

  def test_table_creation
    assert_true @@mysql2psql.writer.exists?('numeric_types_basics')
  end

end