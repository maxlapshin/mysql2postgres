require 'rubygems'
begin
  gem 'test-unit'
  require "test/unit"
rescue LoadError
  # assume using stdlib Test:Unit
  require 'test/unit'
end

require 'ext_test_unit'

def get_test_reader(configfile)
  options = Mysql2psql::ConfigBase.new( "#{File.dirname(__FILE__)}/../fixtures/#{configfile}" )
  seed_data = "#{File.dirname(__FILE__)}/../fixtures/seed_integration_tests.sql"
  rc=system("mysql -u#{options.mysqlusername} #{options.mysqldatabase} < #{seed_data}")
  raise StandardError unless rc
  Mysql2psql::MysqlReader.new(options)
rescue
  raise StandardError.new("Failed to initialize integration test db. See README for setup requirements.")  
end

