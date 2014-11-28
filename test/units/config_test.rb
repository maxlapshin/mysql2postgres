require 'test_helper'

require 'mysql2psql/config'

class ConfigTest < Test::Unit::TestCase
  attr_reader :config_all_opts
  def setup
    @config_all_opts = YAML.load_file "#{File.dirname(__FILE__)}/../fixtures/config_all_options.yml"
  end

  def test_config_loaded
    value = Mysql2psql::Config.new(config_all_opts)
    assert_not_nil value
  end

end
