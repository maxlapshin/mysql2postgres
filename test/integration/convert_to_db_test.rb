require 'test_helper'

require 'mysql2psql'

class ConvertToDbTest < Test::Unit::TestCase
  class << self
    def startup
      configfile = "#{File.dirname(__FILE__)}/../fixtures/config_localmysql_to_db_convert_all.yml"
      seed_test_database
      @@mysql2psql = Mysql2psql.new([configfile])
      @@mysql2psql.convert
    end
    def shutdown
    end
  end
  def setup
  end
  def teardown
  end


end