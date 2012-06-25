require 'mysql2psql/errors'
require 'mysql2psql/version'
require 'mysql2psql/config'
require 'mysql2psql/converter'
require 'mysql2psql/mysql_reader'
require 'mysql2psql/writer'
require 'mysql2psql/postgres_writer'
require 'mysql2psql/postgres_file_writer.rb'
require 'mysql2psql/postgres_activerecord_writer.rb'

class Mysql2psql
  
  attr_reader :options, :reader, :writer
  
  def initialize(yaml)
    
    # help if args.length==1 && args[0] =~ /^-.?|^-*he?l?p?$/i 
    # configfile = args[0] || File.expand_path('mysql2psql.yml')
    
    @options = Config.new( yaml )
    
  end
  
  def convert
    
    @reader = MysqlReader.new( options )

    # if options.destfile(nil)
    #  @writer = PostgresFileWriter.new(options.destfile)
    # else
    #  @writer = PostgresDbWriter.new(options)
    # end
    
    tag = Time.new.to_s.gsub(/((\-)|( )|(:))+/, '')
    
    filename = tag + '_output.sql'

    @writer = PostgresActiveRecordWriter.new(filename, options)

    Converter.new(reader, writer, options).convert
    
    writer.inload
        
  end

end