require 'mysql2psql/postgres_writer'
require 'mysql2psql/connection'

class Mysql2psql

  class PostgresDbWriter < PostgresFileWriter
  
    attr_reader :connection, :filename
  
    def initialize(filename, options)
      # note that the superclass opens and truncates filename for writing
      super(filename)
      @filename = filename
      @connection = Connection.new(options)
    end
    
    def inload(path = filename)
      connection.load_file(path)    
    end

    def clear_schema
      connection.clear_schema
    end

  end

end
