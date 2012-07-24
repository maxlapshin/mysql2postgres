require 'mysql2psql/postgres_writer'
require 'mysql2psql/connection'

class Mysql2psql

  class PostgresDbWriter < PostgresFileWriter
  
    attr_reader :connection, :filename
  
    def initialize(filename, options)

      super(filename)
    
      @filename = filename
    
      @connection = Connection.new(options)
    
    end
    
    def inload
  
      File.open(filename, 'r') do |file|
          
        file.each_line do |line|
          
          connection.execute(line)
          
        end
        
        connection.flush
        
      end
    
    end

  end

end
