require 'test_helper'
require 'tempfile'

require 'mysql2psql/config'

class ConfigTest < Test::Unit::TestCase
  def setup
    @configfile_all_opts = "#{File.dirname(__FILE__)}/../fixtures/config_all_options.yml"
    @configfile_not_found = "#{File.dirname(__FILE__)}/../fixtures/config_not_found.yml.do_not_create_this_file"
    f = Tempfile.new('mysql2psql_config_test')
    @configfile_new = f.path
    f.close!()
  end
  def teardown
    File.delete(@configfile_new) if File.exists?(@configfile_new)
  end

  def test_config_loaded
    value = Mysql2psql::Config.new(@configfile_all_opts, false)
    assert_not_nil value
  end
  
  def test_config_file_not_found
    assert_raise(Mysql2psql::Config::ConfigurationFileNotFound) do
      value = Mysql2psql::Config.new(@configfile_not_found, false)
    end
  end
  def test_initialize_new_config_file
    assert_raise(Mysql2psql::Config::ConfigurationFileInitialized) do
      value = Mysql2psql::Config.new(@configfile_new, true)
    end
  end
end