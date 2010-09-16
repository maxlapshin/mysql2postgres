require 'mysql2psql/version'
require 'mysql2psql/config'



class Mysql2psql
  
  def initialize(*args)
    puts "args:#{args.inspect}"
    puts "#{File.dirname(__FILE__)}/config.yml" 
   
    options = Config.new( ARGV[0] || "#{File.dirname(__FILE__)}/config.yml" )

#    reader = MysqlReader.new(
#      options.mysqlhostname('localhost'), options.mysqlusername, options.mysqlpassword, 
#      options.mysqldatabase, options.mysqlport, options.mysqlsocket )

#    if options.destfile(nil)
#      writer = PostgresFileWriter.new(options.destfile)
#    else
#      writer = PostgresDbWriter.new(
#        options.pghostname('localhost'), options.pgusername, options.pgpassword, 
#        options.pgdatabase, options.pgport(5432).to_i )
#    end
  
    #Converter.new(reader, writer, options).convert
  end
end