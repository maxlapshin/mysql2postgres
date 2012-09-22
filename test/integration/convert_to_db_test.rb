require 'test_helper'

require 'mysqltopostgres'

class ConvertToDbTest < Test::Unit::TestCase

  class << self
    def startup
      seed_test_database
      @@options=get_test_config_by_label(:localmysql_to_db_convert_all)
      @@mysql2psql = Mysql2psql.new([@@options.filepath])
      @@mysql2psql.convert
      @@mysql2psql.writer.open
    end
    def shutdown
      @@mysql2psql.writer.close
      delete_files_for_test_config(@@options)
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