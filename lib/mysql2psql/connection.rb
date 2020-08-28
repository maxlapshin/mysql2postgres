class Mysql2psql
  class Connection
    attr_reader :conn, :adapter, :hostname, :login, :password, :database, :schema, :port, :environment, :jruby, :copy_manager, :stream, :is_copying

    def initialize(options)
      # Rails-centric stuffs

      @environment = ENV['RAILS_ENV'].nil? ? 'development' : ENV['RAILS_ENV']

      if options.key?('config') && options['config'].key?('destination') && options['config']['destination'].key?(environment)

        pg_options = Config.new(YAML.load(options['config']['destination'][environment].to_yaml))
        @hostname, @login, @password, @database, @port = pg_options.host('localhost'), pg_options.username, pg_options.password, pg_options.database, pg_options.port(5432).to_s
        @database, @schema = database.split(':')

        @adapter = pg_options.adapter('jdbcpostgresql')

      else
        fail 'Unable to locate PostgreSQL destination environment in the configuration file'
      end

      if RUBY_PLATFORM == 'java'
        @jruby = true

        ActiveRecord::Base.establish_connection(
          adapter: adapter,
          database: database,
          username: login,
          password: password,
          host: hostname,
          port: port)

        @conn = ActiveRecord::Base.connection_pool.checkout

        unless conn.nil?
          raw_connection = conn.raw_connection
          @copy_manager = org.postgresql.copy.CopyManager.new(raw_connection.connection)
        else
          raise_nil_connection
        end

      else
        @jruby = false

        @conn = PG::Connection.open(dbname: database, user: login, password: password, host: hostname, port: port)

        if conn.nil?
          raise_nil_connection
        end

      end

      @is_copying = false
      @current_statement = ''
    end

    # ensure that the copy is completed, in case we hadn't seen a '\.' in the data stream.
    def flush
      if jruby
        stream.end_copy if @is_copying
      else
        conn.put_copy_end
      end
    rescue => e
      $stderr.puts e
    ensure
      @is_copying = false
    end

    def execute(sql)
      if sql.match(/^COPY /) && !is_copying
        # sql.chomp!   # cHomp! cHomp!

        if jruby
          @stream = copy_manager.copy_in(sql)
        else
          conn.exec(sql)
        end

        @is_copying = true

      elsif sql.match(/^(ALTER|CREATE|DROP|SELECT|SET|TRUNCATE) /) && !is_copying

        @current_statement = sql

      else

        if is_copying

          if sql.chomp == '\.' || sql.chomp.match(/^$/)

            flush

          else

            if jruby

              begin
                row = sql.to_java_bytes
                stream.write_to_copy(row, 0, row.length)

              rescue => e

                stream.cancel_copy
                @is_copying = false
                $stderr.puts e

                raise e
              end

            else

              begin

                until conn.put_copy_data(sql)
                  $stderr.puts '  waiting for connection to be writable...'
                  sleep 0.1
                end

              rescue => e
                @is_copying = false
                $stderr.puts e
                raise e
              end
            end
          end
        elsif @current_statement.length > 0
          @current_statement << ' '
          @current_statement << sql
        else
          # maybe a comment line?
        end
      end

      if @current_statement.match(/;$/)
        run_statement(@current_statement)
        @current_statement = ''
      end
    end

    # we're done talking to the database, so close the connection cleanly.
    def finish
      if jruby
        ActiveRecord::Base.connection_pool.checkin(@conn) if @conn
      else
        @conn.finish if @conn
      end
    end

    # given a file containing psql syntax at path, pipe it down to the database.
    def load_file(path)
      if @conn
        File.open(path, 'r:UTF-8') do |file|
          file.each_line do |line|
            execute(line)
          end
          flush
        end
        finish
      else
        raise_nil_connection
      end
    end

    def clear_schema
      statements = ['DROP SCHEMA PUBLIC CASCADE', 'CREATE SCHEMA PUBLIC']
      statements.each do |statement|
        run_statement(statement)
      end
    end

    def raise_nil_connection
      fail 'No Connection'
    end

    private

    def run_statement(statement)
      method = jruby ? :execute : :exec
      @conn.send(method, statement)
    end
  end
end
