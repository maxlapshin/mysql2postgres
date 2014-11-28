require 'test_helper'

require 'mysqltopostgres'

class PostgresFileWriterTest < Test::Unit::TestCase
  attr_accessor :destfile
  def setup
    @destfile = get_temp_file('mysql2psql_test_destfile')
  rescue => e
    raise StandardError.new('Failed to initialize integration test db. See README for setup requirements.')
  end

  def teardown
    File.delete(destfile) if File.exist?(destfile)
  end

  def test_basic_write
    writer = Mysql2psql::PostgresFileWriter.new(destfile)
    writer.close
    content = IO.read(destfile)
    assert_not_nil content.match("SET client_encoding = 'UTF8'")
    assert_nil content.match('unobtanium')
  end
end
