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

  def test_config_option_pgdatabase_as_array_index
    expected = 'somename'
    config = Mysql2psql::Config.new(configfile_all_opts, false)
    assert_equal expected,config[:pgdatabase]
  end
  def test_template_option_to_filename
    expected = 'test_filename'
    value = Mysql2psql::Config.template({ :to_filename => expected })
    assert_match /file: #{expected}/,value
  end
  def test_template_option_suppress_data
    expected = true
    value = Mysql2psql::Config.template({ :suppress_data => expected })
    assert_match /suppress_data: #{expected}/,value #NB: option spelling needs fixing
  end
  def test_template_option_suppress_ddl
    expected = true
    value = Mysql2psql::Config.template({ :suppress_ddl => expected })
    assert_match /suppress_ddl: #{expected}/,value #NB: option spelling needs fixing
  end
  def test_template_option_suppress_sequence_update
    expected = true
    value = Mysql2psql::Config.template({ :suppress_sequence_update => expected })
    assert_match /suppress_sequence_update: #{expected}/,value #NB: option spelling needs fixing
  end
  def test_template_option_suppress_indexes
    expected = true
    value = Mysql2psql::Config.template({ :suppress_indexes => expected })
    assert_match /suppress_indexes: #{expected}/,value #NB: option spelling needs fixing
  end
  def test_template_option_force_truncate
    expected = true
    value = Mysql2psql::Config.template({ :force_truncate => expected })
    assert_match /force_truncate: #{expected}/,value
  end
  def test_template_option_use_timezones
    expected = true
    value = Mysql2psql::Config.template({ :use_timezones => expected })
    assert_match /use_timezones: #{expected}/,value
  end
end