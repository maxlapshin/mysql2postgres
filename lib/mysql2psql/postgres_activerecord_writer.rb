require 'mysql2psql/postgres_writer'


class Mysql2psql

  class PostgresActiveRecordWriter < PostgresFileWriter
  
    attr_reader :conn, :adapter, :hostname, :login, :password, :database, :schema, :port, :filename, :environment
  
    def initialize(filename, options)

      super(filename)
    
      @filename = filename
    
      # Rails-centric stuffs
      @environment = ENV['RAILS_ENV'].nil? ? 'development' : ENV['RAILS_ENV']

      if options.has_key?('config') and options['config'].has_key?('destination') and options['config']['destination'].has_key?(environment)
      
        pg_options = Config.new(YAML::load(options['config']['destination'][environment].to_yaml))
        @hostname, @login, @password, @database, @port = pg_options.hostname('localhost'), pg_options.username, pg_options.password, pg_options.database, pg_options.port(5432).to_s  
        @database, @schema = database.split(":")
      
        @adapter = pg_options.adapter("jdbcpostgresql")
      
      else
        raise "Unable to locate PostgreSQL destination environment in database.yml"
      end
    
    end
    
    def inload
    
      if RUBY_PLATFORM == 'java'
          
          File.open(filename, 'r') do |file|
            
            ActiveRecord::Base.establish_connection(
              :adapter  => adapter,
              :database => database,
              :username => login,
              :password => password,
              :host     => hostname,
              :port     => port)
            
            connection = ActiveRecord::Base.connection_pool.checkout
            
            unless connection.nil?
              raw_connection = connection.raw_connection
              copy_manager = org.postgresql.copy.CopyManager.new(raw_connection.connection)
            else
              raise "No Connection to ActiveRecord"
            end
            
            is_copying = false
            
            stream = nil
            
              file.each_line do |line|
                
                if line.match(/^TRUNCATE /)
                  line.chomp!
                  
                  connection.execute line
                  
                end
              
                if line.match(/^COPY /) and ! is_copying
                  line.chomp!
                
                  stream = copy_manager.copy_in(line)
                
                  is_copying = true
                
                  next
              
                elsif line.match(/^\\\./) and is_copying
              
                  is_copying = false
                  stream.end_copy
                  
                  stream = nil
                
                end
              
                if is_copying and ! stream.nil?
                  # push the data onto the stream
                
                  begin
                    row = line.to_java_bytes
                    stream.write_to_copy(row, 0, row.length)
                  rescue Exception => e
                    stream.cancel_copy
                    raise e
                  end
                  
                end
              
              end
              
          end
          
      end
    
    end

  end

end
