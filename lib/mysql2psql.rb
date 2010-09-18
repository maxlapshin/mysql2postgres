require 'mysql2psql/errors'
require 'mysql2psql/version'
require 'mysql2psql/config'
require 'mysql2psql/converter'
require 'mysql2psql/mysqlreader'
require 'mysql2psql/writer'
require 'mysql2psql/postgres_writer'
require 'mysql2psql/postgres_db_writer.rb'
require 'mysql2psql/postgres_file_writer.rb'


class Mysql2psql
  
  attr_reader :options
  
  def initialize(args)
    configfile = args[0] || File.expand_path('config.yml')
    @options = Config.new( configfile, true )
  end
  
  def convert
    reader = MysqlReader.new( options )

    if options.destfile(nil)
      writer = PostgresFileWriter.new(options.destfile)
    else
      writer = PostgresDbWriter.new(
        options.pghostname('localhost'), options.pgusername, options.pgpassword, 
        options.pgdatabase, options.pgport(5432).to_i )
    end

    Converter.new(reader, writer, options).convert
  end

  def help
    puts <<EOS

EOS
  end
end