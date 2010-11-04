require 'mysql2psql/errors'
require 'mysql2psql/version'
require 'mysql2psql/config'
require 'mysql2psql/converter'
require 'mysql2psql/mysql_reader'
require 'mysql2psql/writer'
require 'mysql2psql/postgres_writer'
require 'mysql2psql/postgres_db_writer.rb'
require 'mysql2psql/postgres_file_writer.rb'


class Mysql2psql
  
  attr_reader :options, :reader, :writer
  
  def initialize(args)
    help if args.length==1 && args[0] =~ /^-.?|^-*he?l?p?$/i 
    configfile = args[0] || File.expand_path('mysql2psql.yml')
    @options = Config.new( configfile, true )
  end
  
  def convert
    @reader = MysqlReader.new( options )

    if options.destfile(nil)
      @writer = PostgresFileWriter.new(options.destfile)
    else
      @writer = PostgresDbWriter.new(options)
    end

    Converter.new(reader, writer, options).convert
  end

  def help
    puts <<EOS
MySQL to PostgreSQL Conversion

EOS
    exit -2
  end
end