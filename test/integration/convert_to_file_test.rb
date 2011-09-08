require 'test_helper'

require 'mysql2psql'

class ConvertToFileTest < Test::Unit::TestCase

  def setup
    seed_test_database
    @options=get_test_config_by_label(:localmysql_to_file_convert_all)
    @mysql2psql = Mysql2psql.new([@options.filepath])
    @mysql2psql.convert
    @content = IO.read(@mysql2psql.options.destfile)
  end
  def teardown
    delete_files_for_test_config(@options)
  end
  def content
    @content
  end

  # verify table creation
  def test_table_creation
    assert_not_nil content.match('DROP TABLE IF EXISTS "numeric_types_basics" CASCADE')
    assert_not_nil content.match(/CREATE TABLE "numeric_types_basics"/)
  end

  # tests for the conversion of numeric types
  def get_basic_numerics_match(column)
    Regexp.new('CREATE TABLE "numeric_types_basics".*"' + column + '" ([^\n]*).*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_tinyint
    match = get_basic_numerics_match( 'f_tinyint' )    
    assert_match /smallint/,match[1]
  end
  def test_basic_numerics_tinyint_u   
    match = get_basic_numerics_match( 'f_tinyint_u' )    
    assert_match /smallint/,match[1]
  end
  def test_basic_numerics_smallint
    match = get_basic_numerics_match( 'f_smallint' )    
    assert_match /smallint/,match[1]
  end
  def test_basic_numerics_smallint_u
    match = get_basic_numerics_match( 'f_smallint_u' )    
    assert_match /integer/,match[1]
  end
  def test_basic_numerics_mediumint
    match = get_basic_numerics_match( 'f_mediumint' )    
    assert_match /integer/,match[1]  
  end
  def test_basic_numerics_int
    match = get_basic_numerics_match( 'f_int' )    
    assert_match /integer/,match[1]   
  end
  def test_basic_numerics_integer
    match = get_basic_numerics_match( 'f_integer' )    
    assert_match /integer/,match[1] 
  end
  def test_basic_numerics_bigint
    match = get_basic_numerics_match( 'f_bigint' )        
    assert_match /bigint/,match[1]
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_bigint" bigint,.*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_real
    match = get_basic_numerics_match( 'f_real' )    
    assert_match /double precision/,match[1]    
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_real" double precision,.*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_double
    match = get_basic_numerics_match( 'f_double' )    
    assert_match /double precision/,match[1]  
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_double" double precision,.*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_float
    match = get_basic_numerics_match( 'f_float' )    
    assert_match /double precision/,match[1]   
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_float" double precision.*\)', Regexp::MULTILINE).match( content )    
  end
  def test_basic_numerics_float_u    
    match = get_basic_numerics_match( 'f_float_u' )    
    assert_match /double precision/,match[1]  
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_float_u" double precision.*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_decimal
    match = get_basic_numerics_match( 'f_decimal' )    
    assert_match /numeric/,match[1] 
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_decimal" numeric\(10, 0\),.*\)', Regexp::MULTILINE).match( content )
  end
  def test_basic_numerics_numeric
    match = get_basic_numerics_match( 'f_numeric' )    
    assert_match /numeric/,match[1]    
    #assert_not_nil Regexp.new('CREATE TABLE "numeric_types_basics".*"f_numeric" numeric\(10, 0\)[\w\n]*\)', Regexp::MULTILINE).match( content )
  end

  # test autoincrement handling
  def test_autoincrement
    assert_not_nil Regexp.new('CREATE TABLE "basic_autoincrement".*"auto_id" integer DEFAULT.*\)', Regexp::MULTILINE).match( content )
  end
end