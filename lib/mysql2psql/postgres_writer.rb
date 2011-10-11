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

    def column_type(column)
      if column[:auto_increment]
        'integer'
      else
        case column[:type]
        when 'char'
          "character(#{column[:length]})"
        when 'varchar'
          "character varying(#{column[:length]})"
        when /tinyint|smallint/
          'smallint'
        when 'real', /float/, 'double precision'
          'double precision'
        when 'decimal'
          "numeric(#{column[:length] || 10}, #{column[:decimals] || 0})"
        when 'datetime', 'timestamp'
          'timestamp without time zone'
        when 'time'
          'time without time zone'
        when 'tinyblob', 'mediumblob', 'longblob', 'blob', 'varbinary'
          'bytea'
        when 'tinytext', 'mediumtext', 'longtext', 'text'
          'text'
        when /^enum/
          enum = column[:type].gsub(/enum|\(|\)/, '')
          max_enum_size = enum.split(',').map{ |check| check.size() -2}.sort[-1]
          "character varying(#{max_enum_size}) check( #{column[:name]} in (#{enum}))"
        when 'integer', 'bigint', 'boolean', 'date'
          column[:type]
        else
          puts "Unknown #{column.inspect}"
          ''
        end
      end
    end
    
    def column_default(column)
      if column[:auto_increment]
        "nextval('#{column[:table_name]}_#{column[:name]}_seq'::regclass)"
      elsif column[:default]
        case column[:type]
        when 'char'
          "#{column[:default]}::char"
        when 'varchar', /^enum/
          "'#{column[:default]}'::character varying"
        when 'integer', 'bigint', /tinyint|smallint/
          column[:default].to_i
        when 'real', /float/
          column[:default].to_f
        when 'decimal', 'double precision'
          column[:default]
        when 'boolean'
          case column[:default]
          when nil
            'NULL'
          when 0, '0', "b'0'"
            'false'
          else
            # Case for 1, '1', "b'1'" (for BIT(1) the data type), or anything non-nil and non-zero (for the TINYINT(1) type)
            'true'
          end
        when 'timestamp', 'datetime', 'date'
          case column[:default]
          when 'CURRENT_TIMESTAMP'
            'CURRENT_TIMESTAMP'
          when '0000-00-00'
            "'1970-01-01'"
          when '0000-00-00 00:00'
            "'1970-01-01 00:00'"
          when '0000-00-00 00:00:00'
            "'1970-01-01 00:00:00'"
          else
            "'#{column[:default]}'"
          end
        when 'time'
          "'#{column[:default]}'"
        else
          # TODO: column[:default] will never be nil here.
          #       Perhaps we should also issue a warning if this case is encountered.
          "#{column[:default] == nil ? 'NULL' : "'"+PGconn.escape(column[:default])+"'"}"
        end
      end
    end

    def column_type_info(column)
      type = column_type(column)
      if type
        not_null = !column[:null] || column[:auto_increment] ? ' NOT NULL' : ''
        default = column[:default] || column[:auto_increment] ? " DEFAULT #{column_default(column)}" : ''
        "#{type}#{default}#{not_null}"
      else
        ''
      end
    end

    def process_row(table, row)
      table.columns.each_with_index do |column, index|
        if column[:type] == 'time'
          row[index] = "%02d:%02d:%02d" % [row[index].hour, row[index].minute, row[index].second]
        elsif row[index].is_a?(Mysql::Time)
          row[index] = row[index].to_s.gsub('0000-00-00 00:00', '1970-01-01 00:00')
          row[index] = row[index].to_s.gsub('0000-00-00 00:00:00', '1970-01-01 00:00:00')
        elsif column[:type] == 'boolean'
          row[index] = (
            case row[index]
            when nil
              '\N' # See note below about null values.
            when 0, "\0"
              'f'
            else
              # Case for 1, "\1" (for the BIT(1) data type), or anything non-nil and non-zero (to handle the TINYINT(1) type)
              't'
            end
          )
        elsif row[index].is_a?(String)
          if column_type(column) == "bytea"
            row[index] = PGconn.escape_bytea(row[index])
          else
            row[index] = row[index].gsub(/\\/, '\\\\\\').gsub(/\n/,'\n').gsub(/\t/,'\t').gsub(/\r/,'\r')
          end
        elsif row[index].nil?
          # Note: '\N' not "\N" is correct here:
          #       The string containing the literal backslash followed by 'N'
          #       represents database NULL value in PostgreSQL's text mode. 
          row[index] = '\N'
        end
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
