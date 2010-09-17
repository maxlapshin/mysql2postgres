require 'config_base'

class Mysql2psql
  
  class Config

    class ConfigurationFileNotFound < MigrathorConfigError
  	end
    class ConfigurationFileInitialized < MigrathorConfigError
  	end

    def initialize(filepath, generate_default_if_not_found = true)
      unless File.exists?(self.class.configfile)
        reset_configfile
        raise ( File.exists?(self.class.configfile) ? ConfigurationFileInitialized.new : ConfigurationFileNotFound.new )
      end
      super(self.class.configfile)
    end

    def reset_configfile
      file = File.new(self.class.configfile,'w')
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

EOS
    end
  end

end