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
        "character varying(#{column[:length]})"

      # Integer and numeric types
      when "integer"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "integer"
      when "bigint"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "bigint"
      when /tinyint|smallint/
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_i}" if default
        "smallint"

      when "boolean"
        default_value = (
          case column[:default]
          when nil
            'NULL'
          when 0, '0', "b'0'"
            'false'
          else
            # Case for 1, '1', "b'1'" (for BIT(1) the data type), or anything non-nil and non-zero (for the TINYINT(1) type)
            'true'
          end
        )
        default = " DEFAULT #{default_value}" if default
        "boolean"
      when "real"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_f}" if default
        "double precision"
      when /float/
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default].to_f}" if default
        "double precision"
      when "decimal"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "numeric(#{column[:length] || 10}, #{column[:decimals] || 0})"

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
          row[index] = "%02d:%02d:%02d" % [row[index].hour, row[index].minute, row[index].second]
        end

        if row[index].is_a?(Mysql::Time)
          row[index] = row[index].to_s.gsub('0000-00-00 00:00', '1970-01-01 00:00')
          row[index] = row[index].to_s.gsub('0000-00-00 00:00:00', '1970-01-01 00:00:00')
        end

        if column_type(column) == "boolean"
          row[index] = (
            case row[index]
            when nil
              nil
            when 0, "\0"
              'f'
            else
              # Case for 1, "\1" (for the BIT(1) data type), or anything non-nil and non-zero (to handle the TINYINT(1) type)
              't'
            end
          )
        end

        if row[index].is_a?(String)
          if column_type(column) == "bytea"
            row[index] = PGconn.escape_bytea(row[index])
          else
            row[index] = row[index].gsub(/\\/, '\\\\\\').gsub(/\n/,'\n').gsub(/\t/,'\t').gsub(/\r/,'\r').gsub(/\0/, '')
          end
        end

        # Note: '\N' not "\N" is correct here:
        #       The string containing the literal backslash followed by 'N'
        #       represents database NULL value in PostgreSQL's text mode. 
        row[index] = '\N' if row[index].nil?
      end
    end

    def truncate(table)
    end

    def sqlfor_set_serial_sequence(table,serial_key,maxval)
      "SELECT pg_catalog.setval('#{table.name}_#{serial_key}_seq', #{maxval}, true);"
    end
    def sqlfor_reset_serial_sequence(table,serial_key,maxval)
      "SELECT pg_catalog.setval(pg_get_serial_sequence('#{table.name}', '#{serial_key}'), #{maxval}, true);"
    end

  end

end
