require 'mysql2psql/errors'
require 'mysql2psql/version'
require 'mysql2psql/config'
require 'mysql2psql/converter'
require 'mysql2psql/mysql_reader'
require 'mysql2psql/writer'
require 'mysql2psql/postgres_writer'
require 'mysql2psql/postgres_file_writer.rb'
require 'mysql2psql/postgres_db_writer.rb'

class Mysql2psql
  
  attr_reader :options, :reader, :writer
  
  def initialize(yaml)
    
    @options = Config.new( yaml )
    
  end
  
  def convert
    
    @reader = MysqlReader.new( options )
    
    tag = Time.new.to_s.gsub(/((\-)|( )|(:))+/, '')
    
    filename = File.expand_path('./' + tag + '_output.sql')

    @writer = PostgresDbWriter.new(filename, options)

    Converter.new(reader, writer, options).convert
    
    if options.config['remove_dump_file']
      File.delete filename if File::exist?( filename )
    end
        
  end

end