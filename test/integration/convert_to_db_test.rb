require 'test_helper'

require 'mysql2psql'

class ConvertToDbTest < Test::Unit::TestCase

  def setup
    seed_test_database
    @options=get_test_config_by_label(:localmysql_to_db_convert_all)
    @mysql2psql = Mysql2psql.new([@options.filepath])
    @mysql2psql.convert
    @mysql2psql.writer.open
  end
  def teardown
    @mysql2psql.writer.close
    delete_files_for_test_config(@options)
  end

  def test_table_creation
    assert_true @mysql2psql.writer.exists?('numeric_types_basics')
    assert_true @mysql2psql.writer.exists?('basic_autoincrement')
    assert_true @mysql2psql.writer.exists?('numeric_type_floats')
  end

end