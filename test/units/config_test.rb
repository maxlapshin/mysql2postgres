require 'test_helper'

require 'mysql2psql/config'

class ConfigTest < Test::Unit::TestCase
  attr_reader :configfile_new, :configfile_all_opts, :configfile_not_found
  def setup
    @configfile_all_opts = "#{File.dirname(__FILE__)}/../fixtures/config_all_options.yml"
    @configfile_not_found = "#{File.dirname(__FILE__)}/../fixtures/config_not_found.yml.do_not_create_this_file"
    @configfile_new = get_temp_file('mysql2psql_test_config')
  end
  def teardown
    File.delete(configfile_new) if File.exists?(configfile_new)
  end

  def test_config_loaded
    value = Mysql2psql::Config.new(configfile_all_opts, false)
    assert_not_nil value
  end
  
  def test_config_file_not_found
    assert_raise(Mysql2psql::ConfigurationFileNotFound) do
      value = Mysql2psql::Config.new(configfile_not_found, false)
    end
  end
  def test_initialize_new_config_file
    assert_raise(Mysql2psql::ConfigurationFileInitialized) do
      value = Mysql2psql::Config.new(configfile_new, true)
    end
  end
end