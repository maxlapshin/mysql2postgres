
class Mysql2psql

  class Connection
  
    attr_reader :conn, :adapter, :hostname, :login, :password, :database, :schema, :port, :environment, :jruby, :copy_manager, :stream, :is_copying
  
    def initialize(options)
      
      # Rails-centric stuffs
      @environment = ENV['RAILS_ENV'].nil? ? 'development' : ENV['RAILS_ENV']

      if options.has_key?('config') and options['config'].has_key?('destination') and options['config']['destination'].has_key?(environment)
      
        pg_options = Config.new(YAML::load(options['config']['destination'][environment].to_yaml))
        @hostname, @login, @password, @database, @port = pg_options.hostname('localhost'), pg_options.username, pg_options.password, pg_options.database, pg_options.port(5432).to_s  
        @database, @schema = database.split(":")
      
        @adapter = pg_options.adapter("jdbcpostgresql")
      
      else
        raise "Unable to locate PostgreSQL destination environment in the configuration file"
      end
      
      if RUBY_PLATFORM == 'java'
        @jruby = true
        
        ActiveRecord::Base.establish_connection(
          :adapter  => adapter,
          :database => database,
          :username => login,
          :password => password,
          :host     => hostname,
          :port     => port)
            
        @conn = ActiveRecord::Base.connection_pool.checkout
            
        unless conn.nil?
          raw_connection = conn.raw_connection
          @copy_manager = org.postgresql.copy.CopyManager.new(raw_connection.connection)
        else
          raise_nil_connection
        end
        
      else
        @jruby = false
        
        @conn = PG.connect( dbname: database, user: login, password: password, host: hostname, port: port )
        
        unless conn.nil?
          
        else
          raise_nil_connection
        end
        
      end
      
      @is_copying = false
      
    end
    
    def flush
      
      @is_copying = false
      
      begin
          
        if jruby
          stream.end_copy
        else
          conn.put_copy_end
        end
      
      rescue Exception => e
        $stderr.puts e
      end
      
      $stderr.puts "==> Ending Copy..."
      
    end
    
    def execute(sql)
      
      if sql.match(/^COPY /) and ! is_copying
        # sql.chomp!   # cHomp! cHomp!

        $stderr.puts sql + "\n"
        
        if jruby
          @stream = copy_manager.copy_in(sql)
        else
          conn.exec( sql )
        end
        
        @is_copying = true
        
      elsif sql.match(/^TRUNCATE /) and ! is_copying

        $stderr.puts "===> ERR: TRUNCATE is not implemented!"
        @is_copying = false
        
      elsif sql.match(/^ALTER /) and ! is_copying
        
        $stderr.puts "===> ERR: ALTER is not implemented!"
        @is_copying = false

      else

        $stderr.puts "==> #{sql}"
        
        if is_copying
          
          if sql.chomp == '\.' or sql.chomp.match(/^$/)

            flush
          
          else
          
            if jruby
            
              begin
                row = sql.to_java_bytes
                stream.write_to_copy(row, 0, row.length)
                
              rescue Exception => e
              
                stream.cancel_copy
                @is_copying = false
                $stderr.puts e
              
                raise e
              end
            
            else
            
              begin
              
                until conn.put_copy_data( sql )
                  $stderr.puts "  waiting for connection to be writable..."
                  sleep 0.1
                end
              
              rescue Exception => e
                @is_copying = false
                $stderr.puts e
                raise e
              end
            
            end
          
          end
        
        else
          
          $stderr.puts "==> ERR: Not Copying"
        
        end

      end
      
    end
    
    def raise_nil_connection
      raise "No Connection"
    end
    
  end
  
end