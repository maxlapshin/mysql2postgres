require 'test_helper'

require 'mysqltopostgres'

class ConvertToFileTest < Test::Unit::TestCase
  class << self
    def startup
      seed_test_database
      @@options = get_test_config_by_label(:localmysql_to_file_convert_all)
      @@mysql2psql = Mysql2psql.new(@@options)
      @@mysql2psql.convert
      @@content = IO.read(@@mysql2psql.options.destfile)
    end

    def shutdown
      delete_files_for_test_config(@@options)
    end
  end
  def setup
  end

  def teardown
  end

  def content
    @@content
  end

  def test_table_creation
    assert_not_nil content.match('DROP TABLE IF EXISTS "numeric_types_basics" CASCADE')
    assert_not_nil content.match(/CREATE TABLE "numeric_types_basics"/)
  end

  def test_basic_numerics_tinyint
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_tinyint" smallint,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_smallint
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_smallint" integer,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_mediumint
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_mediumint" integer,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_int
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_int" integer,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_integer
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_integer" integer,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_bigint
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_bigint" bigint,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_real
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_real" double precision,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_double
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_double" double precision,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_float
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_float" double precision,.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_decimal
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_decimal" numeric\(10, 0\),.*\)', Regexp::MULTILINE).match(content)
  end

  def test_basic_numerics_numeric
    assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_numeric" numeric\(10, 0\)[\w\n]*\)', Regexp::MULTILINE).match(content)
  end
end
