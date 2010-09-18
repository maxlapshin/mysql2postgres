require 'test_helper'

require 'mysql2psql'

class PostgresDbWriterBaseTest < Test::Unit::TestCase
  attr_accessor :options
  class << self
    def startup
      seed_test_database
    end
    def shutdown
    end
  end
  def setup

  end
  
  def test_pg_connection
  end

end