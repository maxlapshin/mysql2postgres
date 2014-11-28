require 'test_helper'

require 'mysql2psql/postgres_db_writer'

class PostgresDbWriterBaseTest < Test::Unit::TestCase
  class << self
    def startup
      seed_test_database
      @@options = get_test_config_by_label(:localmysql_to_db_convert_nothing)
    end

  end
  def setup
  end

  def teardown
  end

  def options
    @@options
  end

  def test_pg_connection
    assert_nothing_raised do
      reader = Mysql2psql::PostgresDbWriter.new(options)
    end
  end
end
