require 'rubygems'
begin
  gem 'test-unit'
  require "test/unit"
rescue LoadError
  # assume using stdlib Test:Unit
  require 'test/unit'
end

require 'ext_test_unit'

def seed_test_database
  options=get_test_config_by_label(:localmysql_to_file_convert_nothing)
  seedfilepath = "#{File.dirname(__FILE__)}/../fixtures/seed_integration_tests.sql"
  mysql_cmd = `which mysql`.empty? ? 'mysql5' : 'mysql'
  rc=system("#{mysql_cmd} -u#{options.mysqlusername} #{options.mysqldatabase} < #{seedfilepath}")
  raise StandardError unless rc
  return true
rescue
  raise StandardError.new("Failed to seed integration test db. See README for setup requirements.")
ensure
  delete_files_for_test_config(options)
end

def get_test_reader(options)
  require 'mysql2psql/mysql_reader'
  Mysql2psql::MysqlReader.new(options)
rescue
  raise StandardError.new("Failed to initialize integration test db. See README for setup requirements.")  
end

def get_test_file_writer(options)
  require 'mysql2psql/postgres_file_writer'
  Mysql2psql::PostgresFileWriter.new(options.destfile)
rescue => e
  puts e.inspect
  raise StandardError.new("Failed to initialize file writer from #{options.inspect}. See README for setup requirements.")
end

def get_test_converter(options)
  require 'mysql2psql/converter'
  reader=get_test_reader(options)
  writer=get_test_file_writer(options)
  Mysql2psql::Converter.new(reader,writer,options)
rescue
  raise StandardError.new("Failed to initialize converter from #{options.inspect}. See README for setup requirements.")
end

def get_temp_file(basename)
  require 'tempfile'
  f = Tempfile.new(basename)
  path = f.path
  f.close!()
  path
end


def get_new_test_config(to_file = true, include_tables = [], exclude_tables = [], supress_data = false, supress_ddl = false, force_truncate = false)
  require 'mysql2psql/config'
  require 'mysql2psql/config_base'
  to_filename = to_file ? get_temp_file('mysql2psql_tmp_output') : nil
  configtext = Mysql2psql::Config.template(to_filename, include_tables, exclude_tables, supress_data, supress_ddl, force_truncate)
  configfile=get_temp_file('mysql2psql_tmp_config')
  File.open(configfile, 'w') {|f| f.write(configtext) }
  Mysql2psql::ConfigBase.new( configfile )
rescue
  raise StandardError.new("Failed to initialize options from #{configfile}. See README for setup requirements.")
end

def get_test_config_by_label(name)
  case name
  when :localmysql_to_file_convert_nothing
    get_new_test_config(true, ['unobtainium'], ['kryptonite'], true, true, false)
  when :localmysql_to_file_convert_all
    get_new_test_config(true, [], [], false, false, true)
  when :localmysql_to_db_convert_all
    get_new_test_config(false, [], [], false, false, false)
  when :localmysql_to_db_convert_nothing
    get_new_test_config(false, ['unobtainium'], ['kryptonite'], true, true, false)
  else
    raise StandardError.new("Invalid label: #{name}")
  end
end

def delete_files_for_test_config(config)
  File.delete(config.destfile) if File.exists?(config.destfile)
  File.delete(config.filepath) if File.exists?(config.filepath)
rescue
end