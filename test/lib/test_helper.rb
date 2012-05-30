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

def get_new_test_config(options={})
  require 'mysql2psql/config'
  require 'mysql2psql/config_base'
  if options.delete(:to_file)
    options[:to_filename] = get_temp_file('mysql2psql_tmp_output')
  end
  configtext = Mysql2psql::Config.template(options)
  configfile=get_temp_file('mysql2psql_tmp_config')
  File.open(configfile, 'w') {|f| f.write(configtext) }
  Mysql2psql::ConfigBase.new( configfile )
rescue
  raise StandardError.new("Failed to initialize options from #{configfile}. See README for setup requirements.")
end

def get_test_config_by_label(name)
  options = case name
  when :localmysql_to_file_convert_nothing
    {
      :to_file => true,
      :include_tables => ['unobtainium'],
      :exclude_tables => ['kryptonite'],
      :suppress_data => true,
      :suppress_ddl => true,
      :supress_sequence_update => false,
      :suppress_indexes => false,
      :force_truncate => false,
      :use_timezones => false
    }
  when :localmysql_to_file_convert_all
    {
      :to_file => true,
      :include_tables => [],
      :exclude_tables => [],
      :suppress_data => false,
      :suppress_ddl => false,
      :supress_sequence_update => false,
      :suppress_indexes => false,
      :force_truncate => true,
      :use_timezones => false
    }
  when :localmysql_to_db_convert_all
    {
      :to_file => false,
      :include_tables => [],
      :exclude_tables => [],
      :suppress_data => false,
      :suppress_ddl => false,
      :supress_sequence_update => false,
      :suppress_indexes => false,
      :force_truncate => false,
      :use_timezones => false
    }
  when :localmysql_to_db_convert_nothing
    {
      :to_file => false,
      :include_tables => ['unobtainium'],
      :exclude_tables => ['kryptonite'],
      :suppress_data => true,
      :suppress_ddl => true,
      :supress_sequence_update => false,
      :suppress_indexes => false,
      :force_truncate => false,
      :use_timezones => false
    }
  else
    raise StandardError.new("Invalid label: #{name}")
  end
  get_new_test_config(options)
end

def delete_files_for_test_config(config)
  File.delete(config.destfile) if File.exists?(config.destfile)
  File.delete(config.filepath) if File.exists?(config.filepath)
rescue
end