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

    # Returns template file text given +options+ hash which may include:
    # :to_filename - default: nil
    # :include_tables - default: []
    # :exclude_tables - default: []
    # :suppress_data - default: false
    # :suppress_ddl - default: false
    # :suppress_sequence_update - default: false
    # :suppress_indexes - default: false
    # :force_truncate - default: false
    # :use_timezones - default: false
    def self.template(options={})
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
 file: #{ options[:to_filename] || ''}
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
      include_tables = options[:include_tables] || []
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
      exclude_tables = options[:exclude_tables] || []
      if exclude_tables.length>0
        configtext += "\nexclude_tables:\n"
        exclude_tables.each do |t|
          configtext += "- #{t}\n"
        end
      end

      if !options[:suppress_data].nil?
        configtext += <<EOS

# if suppress_data is true, only the schema definition will be exported/migrated, and not the data
suppress_data: #{options[:suppress_data]}
EOS
      end

      if !options[:suppress_ddl].nil?
        configtext += <<EOS

# if suppress_ddl is true, only the data will be exported/imported, and not the schema
suppress_ddl: #{options[:suppress_ddl]}
EOS
      end

      if !options[:suppress_sequence_update].nil?
        configtext += <<EOS

# if suppress_sequence_update is true, the sequences for serial (auto-incrementing) columns
# will not be update to the current maximum value of that column in the database
# if suppress_ddl is not set to true, then this option is implied to be false as well (unless overridden here)
suppress_sequence_update: #{options[:suppress_sequence_update]}
EOS
      end

      if !options[:force_truncate].nil?
        configtext += <<EOS

# if force_truncate is true, forces a table truncate before table loading
force_truncate: #{options[:force_truncate]}
EOS
      end

      if !options[:use_timezones].nil?
        configtext += <<EOS
        
# if use_timezones is true, timestamp/time columns will be created in postgres as "with time zone"
# rather than "without time zone"
use_timezones: #{options[:use_timezones]}
EOS
      end

      if !options[:suppress_indexes].nil?
        configtext += <<EOS

# if suppress_indexes is true, indexes will not be exported/migrated
suppress_indexes: #{options[:suppress_indexes]}
EOS
      end
      configtext
    end

  end

end