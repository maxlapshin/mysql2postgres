require 'pg'

require 'mysql2psql/writer'

class Mysql2psql

  class PostgresWriter < Writer
    def column_description(column)
      "#{PGconn.quote_ident(column[:name])} #{column_type_info(column)}"
    end
  
    def column_type(column)
      column_type_info(column).split(" ").first
    end
  
    def column_type_info(column)
      if column[:auto_increment]
        return "integer DEFAULT nextval('#{column[:table_name]}_#{column[:name]}_seq'::regclass) NOT NULL"
      end
    
      default = column[:default] ? " DEFAULT #{column[:default] == nil ? 'NULL' : "'"+PGconn.escape(column[:default])+"'"}" : nil
      null = column[:null] ? "" : " NOT NULL"
      type = 
      case column[:type]
    
      # String types
      when "char"
        default = default + "::char" if default
        "character(#{column[:length]})"
      when "varchar"
        default = default + "::character varying" if default
  #      puts "VARCHAR: #{column.inspect}"
        "character varying(#{column[:length]})"
      
      # Integer and numeric types
      when "integer"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "integer"
      when "bigint"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "bigint"
      when "tinyint"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "smallint"
    
      when "boolean"
        default = " DEFAULT #{column[:default].to_i == 1 ? 'true' : 'false'}" if default
        "boolean"
      when "float"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_f}" if default
        "real"
      when "float unsigned"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_f}" if default
        "real"
      when "decimal"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "numeric(#{column[:length] || 10}, #{column[:decimals] || 5})"

      when "double precision"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "double precision"

      # Mysql datetime fields
      when "datetime"
        default = nil
        "timestamp without time zone"
      when "date"
        default = nil
        "date"
      when "timestamp"
        default = " DEFAULT CURRENT_TIMESTAMP" if column[:default] == "CURRENT_TIMESTAMP"
        default = " DEFAULT '1970-01-01 00:00'" if column[:default] == "0000-00-00 00:00"
        default = " DEFAULT '1970-01-01 00:00:00'" if column[:default] == "0000-00-00 00:00:00"
        "timestamp without time zone"
      when "time"
        default = " DEFAULT NOW()" if default
        "time without time zone"

      when "tinyblob"
        "bytea"
      when "mediumblob"
        "bytea"
      when "longblob"
        "bytea"
      when "blob"
        "bytea"
      when "varbinary"
        "bytea"
      when "tinytext"
        "text"
      when "mediumtext"
        "text"
      when "longtext"
        "text"
      when "text"
        "text"
      when /^enum/
        default = default + "::character varying" if default
        enum = column[:type].gsub(/enum|\(|\)/, '')
        max_enum_size = enum.split(',').map{ |check| check.size() -2}.sort[-1]
        "character varying(#{max_enum_size}) check( #{column[:name]} in (#{enum}))"
      else
        puts "Unknown #{column.inspect}"
        column[:type].inspect
        return ""
      end
      "#{type}#{default}#{null}"
    end
  
    def process_row(table, row)
    	table.columns.each_with_index do |column, index|

          if column[:type] == "time"
            begin
              row[index] = "%02d:%02d:%02d" % [row[index].hour, row[index].minute, row[index].second]
            rescue
              # nil
            end
          end
        
          if row[index].is_a?(Mysql::Time)
            row[index] = row[index].to_s.gsub('0000-00-00 00:00', '1970-01-01 00:00')
            row[index] = row[index].to_s.gsub('0000-00-00 00:00:00', '1970-01-01 00:00:00')
          end
        
          if column_type(column) == "boolean"
            row[index] = row[index] == 1 ? 't' : row[index] == 0 ? 'f' : row[index]
          end
        
          if row[index].is_a?(String)
            if column_type(column) == "bytea"
              row[index] = PGconn.escape_bytea(row[index])
            else
              row[index] = row[index].gsub(/\\/, '\\\\\\').gsub(/\n/,'\n').gsub(/\t/,'\t').gsub(/\r/,'\r').gsub(/\0/, '')
            end
          end
        
          row[index] = '\N' if !row[index]
        end
    end
  
    def truncate(table)
    end
  
  end

end
