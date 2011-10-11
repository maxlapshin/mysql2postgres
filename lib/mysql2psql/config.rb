require 'mysql2psql/config_base'

class Mysql2psql

  class Config < ConfigBase

    def initialize(configfilepath, generate_default_if_not_found = true)
      unless File.exists?(configfilepath)
        reset_configfile(configfilepath) if generate_default_if_not_found
        if File.exists?(configfilepath)
          raise Mysql2psql::ConfigurationFileInitialized.new("\n
No configuration file found.
A new file has been initialized at: #{configfilepath}
Please review the configuration and retry..\n\n\n")
        else
          raise Mysql2psql::ConfigurationFileNotFound.new("cannot load config file #{configfilepath}")
        end
      end
      super(configfilepath)
    end

    def reset_configfile(filepath)
      file = File.new(filepath,'w')
      self.class.template.each_line do | line|
        file.puts line
      end
      file.close
    end

    def self.template(to_filename = nil, include_tables = [], exclude_tables = [], suppress_data = false, suppress_ddl = false, force_truncate = false)
      configtext = <<EOS
mysql:
 hostname: localhost
 port: 3306
 socket:
 username: mysql2psql
 password:
 database: mysql2psql_test

destination:
 # if file is given, output goes to file, else postgres
 file: #{ to_filename ? to_filename : ''}
 postgres:
  hostname: localhost
  port: 5432
  username: mysql2psql
  password:
  database: mysql2psql_test

# if tables is given, only the listed tables will be converted.  leave empty to convert all tables.
#tables:
#- table1
#- table2
EOS
      if include_tables.length>0
        configtext += "\ntables:\n"
        include_tables.each do |t|
          configtext += "- #{t}\n"
        end
      end
      configtext += <<EOS
# if exclude_tables is given, exclude the listed tables from the conversion.
#exclude_tables:
#- table3
#- table4

EOS
      if exclude_tables.length>0
        configtext += "\nexclude_tables:\n"
        exclude_tables.each do |t|
          configtext += "- #{t}\n"
        end
      end
      if !suppress_data.nil?
        configtext += <<EOS

# if suppress_data is true, only the schema definition will be exported/migrated, and not the data
suppress_data: #{suppress_data}
EOS
      end
      if !suppress_ddl.nil?
        configtext += <<EOS

# if suppress_ddl is true, only the data will be exported/imported, and not the schema
suppress_ddl: #{suppress_ddl}
EOS
      end
      if !force_truncate.nil?
        configtext += <<EOS

# if force_truncate is true, forces a table truncate before table loading
force_truncate: #{force_truncate}
EOS
      end
      configtext
    end

  end

end