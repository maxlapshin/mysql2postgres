require 'test_helper'

require 'mysql2psql'

class ConvertToDbTest < Test::Unit::TestCase

  def setup
    $stdout = StringIO.new
    $stderr = StringIO.new

    seed_test_database
    @options=get_test_config_by_label(:localmysql_to_db_convert_all)
    @mysql2psql = Mysql2psql.new([@options.filepath])
    @mysql2psql.convert
    @mysql2psql.writer.open
  end

  def teardown
    @mysql2psql.writer.close
    delete_files_for_test_config(@options)
    
    $stdout = STDOUT
    $stderr = STDERR
  end

  def exec_sql_on_psql(sql, parameters=nil)
    @mysql2psql.writer.conn.exec(sql, parameters)
  end

  def get_boolean_test_record(name)
    exec_sql_on_psql('SELECT * FROM test_boolean_conversion WHERE test_name = $1', [name]).first
  end

  def test_table_creation
    assert_true @mysql2psql.writer.exists?('numeric_types_basics')
    assert_true @mysql2psql.writer.exists?('basic_autoincrement')
    assert_true @mysql2psql.writer.exists?('numeric_type_floats')
  end

  def test_boolean_conversion_to_true
    true_record = get_boolean_test_record('test-true')
    assert_equal 't', true_record['bit_1']
    assert_equal 't', true_record['tinyint_1']
    
    true_nonzero_record = get_boolean_test_record('test-true-nonzero')
    assert_equal 't', true_nonzero_record['tinyint_1']
  end

  def test_boolean_conversion_to_false
    false_record = get_boolean_test_record('test-false')
    assert_equal 'f', false_record['bit_1']
    assert_equal 'f', false_record['tinyint_1']
  end

  def test_boolean_conversion_of_null
    null_record = get_boolean_test_record('test-null')
    assert_nil null_record['bit_1']
    assert_nil null_record['tinyint_1']
  end
  
  def test_null_conversion
    result = exec_sql_on_psql('SELECT column_a FROM test_null_conversion').first
    assert_nil result['column_a']
  end
  
  def test_datetime_conversion
    result = exec_sql_on_psql('SELECT column_a, column_f FROM test_datetime_conversion').first
    assert_equal '1970-01-01 00:00:00', result['column_a']
    assert_equal '08:15:30', result['column_f']
  end
  
  def test_datetime_defaults
    result = exec_sql_on_psql(<<-SQL)
      SELECT a.attname,
        pg_catalog.format_type(a.atttypid, a.atttypmod),
        (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
         FROM pg_catalog.pg_attrdef d
         WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) AS default
      FROM pg_catalog.pg_attribute a
      WHERE a.attrelid = 'test_datetime_conversion'::regclass AND a.attnum > 0
    SQL
    
    assert_equal 6, result.count
    
    result.each do |row|
      if row["attname"] == "column_f"
        assert_equal "time without time zone", row["format_type"]
      else
        assert_equal "timestamp without time zone", row["format_type"]
      end
      
      case row["attname"]
      when "column_a"
        assert_nil row["default"]
      when "column_b"
        assert_equal "now()", row["default"]
      when "column_c", "column_d", "column_e"
        assert_equal "'1970-01-01 00:00:00'::timestamp without time zone", row["default"]
      end
    end
  end
  
  def test_index_conversion
    result = exec_sql_on_psql('SELECT pg_get_indexdef(indexrelid) FROM pg_index WHERE indrelid = \'test_index_conversion\'::regclass').first
    assert_equal "CREATE UNIQUE INDEX test_index_conversion_column_a_idx ON test_index_conversion USING btree (column_a)", result["pg_get_indexdef"]
  end
  
  def test_foreign_keys
    result = exec_sql_on_psql("SELECT conname, pg_catalog.pg_get_constraintdef(r.oid, true) as condef FROM pg_catalog.pg_constraint r WHERE r.conrelid = 'test_foreign_keys_child'::regclass")
    expected = {"condef" => "FOREIGN KEY (test_foreign_keys_parent_id) REFERENCES test_foreign_keys_parent(id)", "conname" => "test_foreign_keys_child_test_foreign_keys_parent_id_fkey"}
    assert_equal expected, result.first
  end
  
  def test_output
    $stdout.rewind
    actual = $stdout.read
    
    assert_match /Counting rows of test_foreign_keys_child/, actual
  end
  
  def test_enum
    result = exec_sql_on_psql(<<-SQL)
      SELECT r.conname, pg_catalog.pg_get_constraintdef(r.oid, true)
      FROM pg_catalog.pg_constraint r
      WHERE r.conrelid = 'test_enum'::regclass AND r.contype = 'c'
      ORDER BY 1
    SQL
    
    assert_equal 1, result.count
    assert_equal "CHECK (name::text = ANY (ARRAY['small'::character varying, 'medium'::character varying, 'large'::character varying]::text[]))", result.first["pg_get_constraintdef"]
  end
end