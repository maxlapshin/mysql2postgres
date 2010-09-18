require 'rubygems'
begin
  gem 'test-unit'
  require "test/unit"
rescue LoadError
  # assume using stdlib Test:Unit
  require 'test/unit'
end

require 'ext_test_unit'

def get_test_config(configfile)
  Mysql2psql::ConfigBase.new( "#{File.dirname(__FILE__)}/../fixtures/#{configfile}" )
rescue
  raise StandardError.new("Failed to initialize options from #{configfile}. See README for setup requirements.")
end

def get_test_reader(options)
  seed_data = "#{File.dirname(__FILE__)}/../fixtures/seed_integration_tests.sql"
  rc=system("mysql -u#{options.mysqlusername} #{options.mysqldatabase} < #{seed_data}")
  raise StandardError unless rc
  Mysql2psql::MysqlReader.new(options)
rescue
  raise StandardError.new("Failed to initialize integration test db. See README for setup requirements.")  
end

def get_test_file_writer(options)
  Mysql2psql::PostgresFileWriter.new(options.destfile)
rescue
  raise StandardError.new("Failed to initialize file writer from #{options.inspect}. See README for setup requirements.")
end

def get_test_converter(options)
  reader=get_test_reader(options)
  writer=get_test_file_writer(options)
  Mysql2psql::Converter.new(reader,writer,options)
rescue
  raise StandardError.new("Failed to initialize converter from #{options.inspect}. See README for setup requirements.")
end

def file_contains(filepath,regex)
  rc=false
  File.foreach(filepath) do |line|
    rc = rc || ( line =~ /#{regex}/ ) != nil
  end
  rc
end

def get_temp_file(basename)
  require 'tempfile'
  f = Tempfile.new(basename)
  path = f.path
  f.close!()
  path
end

