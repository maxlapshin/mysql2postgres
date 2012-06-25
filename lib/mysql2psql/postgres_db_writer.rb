require 'postgres-pr/postgres-compat'

require 'mysql2psql/postgres_writer'

class Mysql2psql

class PostgresDbWriter < PostgresWriter
  attr_reader :conn, :hostname, :login, :password, :database, :schema, :port
  
  def initialize(options)
    # @hostname, @login, @password, @database, @port =  
    #  options.pghostname('localhost'), options.pgusername, 
    #  options.pgpassword, options.pgdatabase, options.pgport(5432).to_s
    
    # Rails-centric stuffs
    environment = ENV['RAILS_ENV'].nil? ? 'development' : ENV['RAILS_ENV']

    if options.has_key?('config') and options['config'].has_key?('destination') and options['config']['destination'].has_key?(environment)
      
      pg_options = Config.new(YAML::load(options['config']['destination'][environment].to_yaml))
      @hostname, @login, @password, @database, @port =  
        pg_options.hostname('localhost'), pg_options.username, 
        pg_options.password, pg_options.database, pg_options.port(5432).to_s
        
        @database, @schema = database.split(":")
      
    else
      raise "Unable to locate PostgreSQL destination environment in database.yml"
    end
    
    open
  end

  def open
    @conn = PGconn.new(hostname, port, '', '', database, login, password)
    @conn.exec("SET search_path TO #{PGconn.quote_ident(schema)}") if schema
    @conn.exec("SET client_encoding = 'UTF8'")
    @conn.exec("SET standard_conforming_strings = off") # if @conn.server_version >= 80200
    @conn.exec("SET check_function_bodies = false")
    # @conn.exec("SET client_min_messages = warning")
    
    puts "==> Connected to PostgreSQL server..."
  end
  
  def close
    @conn.close
  end

  def exists?(relname)
    rc = @conn.exec("SELECT COUNT(*) FROM pg_class WHERE relname = '#{relname}'")
    (!rc.nil?) && (rc.to_a.length==1) && (rc.first.count.to_i==1)
  end
  
  def write_table(table)
    puts "Creating table #{table.name}..."
    primary_keys = []
    serial_key = nil
    maxval = nil
    
    columns = table.columns.map do |column|
      if column[:auto_increment]
        serial_key = column[:name]
        maxval = column[:maxval].to_i < 1 ? 1 : column[:maxval] + 1
      end
      if column[:primary_key]
        primary_keys << column[:name]
      end
      "  " + column_description(column)
    end.join(",\n")
    
    if serial_key
      if @conn.server_version < 80200
        serial_key_seq = "#{table.name}_#{serial_key}_seq"
        @conn.exec("DROP SEQUENCE #{serial_key_seq} CASCADE") if exists?(serial_key_seq)
      else
        @conn.exec("DROP SEQUENCE IF EXISTS #{table.name}_#{serial_key}_seq CASCADE")
      end
      @conn.exec <<-EOF
        CREATE SEQUENCE #{table.name}_#{serial_key}_seq
        INCREMENT BY 1
        NO MAXVALUE
        NO MINVALUE
        CACHE 1
      EOF
    
      @conn.exec "SELECT pg_catalog.setval('#{table.name}_#{serial_key}_seq', #{maxval}, true)"
    end
    
    if @conn.server_version < 80200
      @conn.exec "DROP TABLE #{PGconn.quote_ident(table.name)} CASCADE;" if exists?(table.name)
    else
      @conn.exec "DROP TABLE IF EXISTS #{PGconn.quote_ident(table.name)} CASCADE;"
    end
    create_sql = "CREATE TABLE #{PGconn.quote_ident(table.name)} (\n" + columns + "\n)\nWITHOUT OIDS;"
    begin
      @conn.exec(create_sql)
    rescue Exception => e
      puts "Error: \n#{create_sql}"
      raise
    end
    puts "Created table #{table.name}"
 
  end
  
  def write_indexes(table)
    puts "Indexing table #{table.name}..."
    if primary_index = table.indexes.find {|index| index[:primary]}
      @conn.exec("ALTER TABLE #{PGconn.quote_ident(table.name)} ADD CONSTRAINT \"#{table.name}_pkey\" PRIMARY KEY(#{primary_index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")})")
    end
    
    table.indexes.each do |index|
      next if index[:primary]
      unique = index[:unique] ? "UNIQUE " : nil
      
      #MySQL allows an index name which could be equal to a table name, Postgres doesn't
      indexname = index[:name]
      if indexname.eql?(table.name)
        indexnamenew = "#{indexname}_index"
        puts "WARNING: index \"#{indexname}\" equals table name. This is not allowed by postgres and will be renamed to \"#{indexnamenew}\""
        indexname = indexnamenew
      end
      
      if @conn.server_version < 80200
        @conn.exec("DROP INDEX #{PGconn.quote_ident(indexname)} CASCADE;") if exists?(indexname)
      else
        @conn.exec("DROP INDEX IF EXISTS #{PGconn.quote_ident(indexname)} CASCADE;")
      end
      @conn.exec("CREATE #{unique}INDEX #{PGconn.quote_ident(indexname)} ON #{PGconn.quote_ident(table.name)} (#{index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")});")
    end
    
    
    #@conn.exec("VACUUM FULL ANALYZE #{PGconn.quote_ident(table.name)}")
    puts "Indexed table #{table.name}"
  rescue Exception => e
    puts "Couldn't create indexes on #{table} (#{table.indexes.inspect})"
    puts e
    puts e.backtrace[0,3].join("\n")
  end
  
  def write_constraints(table)
    table.foreign_keys.each do |key|
      key_sql = "ALTER TABLE #{PGconn.quote_ident(table.name)} ADD FOREIGN KEY (#{key[:column].map{|c|PGconn.quote_ident(c)}.join(', ')}) REFERENCES #{PGconn.quote_ident(key[:ref_table])}(#{key[:ref_column].map{|c|PGconn.quote_ident(c)}.join(', ')}) ON UPDATE #{key[:on_update]} ON DELETE #{key[:on_delete]}"
      begin
        @conn.exec(key_sql)
      rescue Exception => e
        puts "Error: \n#{key_sql}\n#{e}"
      end
    end
  end
  
  def format_eta (t)
    t = t.to_i
    sec = t % 60
    min = (t / 60) % 60
    hour = t / 3600
    sprintf("%02dh:%02dm:%02ds", hour, min, sec)
  end
  
  def write_contents(table, reader)
    _time1 = Time.now
    copy_line = "COPY #{PGconn.quote_ident(table.name)} (#{table.columns.map {|column| PGconn.quote_ident(column[:name])}.join(", ")}) FROM stdin;"
    puts "==> '#{copy_line}'"
    @conn.exec(copy_line)
    puts "Counting rows of #{table.name}... "
    STDOUT.flush
    rowcount = table.count_rows
    puts "Rows counted"
    puts "Loading #{table.name}..."
    STDOUT.flush
    _counter = reader.paginated_read(table, 1000) do |row, counter|
      line = []
      process_row(table, row)
      @conn.put_copy_data(row.join("\t") + "\n")
       
      if counter != 0 && counter % 20000 == 0
        elapsedTime = Time.now - _time1
        eta = elapsedTime * rowcount / counter - elapsedTime
        etaf = self.format_eta(eta)
        etatimef = (Time.now + eta).strftime("%Y/%m/%d %H:%M")
        printf "\r#{counter} of #{rowcount} rows loaded. [ETA: #{etatimef} (#{etaf})]"
        STDOUT.flush
      end
      
      if counter % 5000 == 0
        @conn.put_copy_end
        @conn.exec(copy_line)
      end
       
    end
    _time2 = Time.now
    puts "\n#{_counter} rows loaded in #{((_time2 - _time1) / 60).round}min #{((_time2 - _time1) % 60).round}s"
#    @conn.putline(".\n")
    @conn.put_copy_end
  end
  
end

end