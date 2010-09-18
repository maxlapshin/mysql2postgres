require 'mysql2psql/config_base'

class Mysql2psql
  
  class Config < ConfigBase

    def initialize(filepath, generate_default_if_not_found = true)
      unless File.exists?(filepath)
        reset_configfile(filepath) if generate_default_if_not_found
        if File.exists?(filepath) 
          raise Mysql2psql::ConfigurationFileInitialized.new("initialized config file #{filepath}")
        else
          raise Mysql2psql::ConfigurationFileNotFound.new("cannot load config file #{filepath}")
        end
      end
      super(filepath)
    end

    def reset_configfile(filepath)
      file = File.new(filepath,'w')
      self.class.template.each_line do | line|
        file.puts line
      end
      file.close
    end
  
    def self.template
      return <<EOS
mysql:
 hostname: localhost
 port: 3306
 socket: /tmp/mysql.sock
 username: somename
 password: secretpassword
 database: somename 

destination:
 # if file is given, output goes to file, else postgres
 file:
 postgres:
  hostname: localhost
  port: 5432
  username: somename
  password: secretpassword
  database: somename

# if tables is given, only the listed tables will be converted.  leave empty to convert all tables.
#tables:
#- table1
#- table2
#- table3
#- table4

# if exclude_tables is given, exclude the listed tables from the conversion.
#exclude_tables:
#- table5
#- table6

# if supress_data is true, only the schema definition will be exported/migrated, and not the data
#supress_data: true

# if supress_ddl is true, only the data will be exported/imported, and not the schema
#supress_ddl: false

# if force_truncate is true, forces a table truncate before table loading
#force_truncate: false

EOS
    end
  end

end