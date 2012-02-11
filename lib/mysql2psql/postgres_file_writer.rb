require 'mysql2psql/postgres_writer'

class Mysql2psql

class PostgresFileWriter < PostgresWriter
  def initialize(file)
    @f = File.open(file, "w+")
    @f << <<-EOF
-- MySQL 2 PostgreSQL dump\n
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
 
EOF
  end
  
  def truncate(table)
    serial_key = nil
    maxval = nil
    
    table.columns.map do |column|
      if column[:auto_increment]
        serial_key = column[:name]
        maxval = column[:maxval].to_i < 1 ? 1 : column[:maxval] + 1
      end
    end

    @f << <<-EOF
-- TRUNCATE #{table.name};
TRUNCATE #{PGconn.quote_ident(table.name)} CASCADE;

EOF
    if serial_key
    @f << <<-EOF
#{sqlfor_reset_serial_sequence(table,serial_key,maxval)}
EOF
    end
  end
  
  def write_sequence_update(table, options)
    serial_key_column = table.columns.detect do |column|
      column[:auto_increment]
    end
    
    if serial_key_column
      serial_key = serial_key_column[:name]
      serial_key_seq = "#{table.name}_#{serial_key}_seq"
      max_value = serial_key_column[:maxval].to_i < 1 ? 1 : serial_key_column[:maxval] + 1
      
      @f << <<-EOF
--
-- Name: #{serial_key_seq}; Type: SEQUENCE; Schema: public
--
EOF

      if !options.supress_ddl
        @f << <<-EOF
DROP SEQUENCE IF EXISTS #{serial_key_seq} CASCADE;
 
CREATE SEQUENCE #{serial_key_seq}
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
EOF
      end
      
      if !options.supress_sequence_update
        @f << <<-EOF
#{sqlfor_set_serial_sequence(table, serial_key_seq, max_value)} 
EOF
      end
    end
  end
  
  def write_table(table, options)
    primary_keys = []
    serial_key = nil
    maxval = nil
    
    columns = table.columns.map do |column|
      if column[:primary_key]
        primary_keys << column[:name]
      end
      "  " + column_description(column, options)
    end.join(",\n")
    
    @f << <<-EOF
-- Table: #{table.name}
 
-- DROP TABLE #{table.name};
DROP TABLE IF EXISTS #{PGconn.quote_ident(table.name)} CASCADE;
 
CREATE TABLE #{PGconn.quote_ident(table.name)} (
EOF
  
    @f << columns
 
    if primary_index = table.indexes.find {|index| index[:primary]}
      @f << ",\n  CONSTRAINT #{table.name}_pkey PRIMARY KEY(#{primary_index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")})"
    end
    
    @f << <<-EOF
\n)
WITHOUT OIDS;
EOF
  
    table.indexes.each do |index|
      next if index[:primary]
      unique = index[:unique] ? "UNIQUE " : nil
      @f << <<-EOF
DROP INDEX IF EXISTS #{PGconn.quote_ident(index[:name])} CASCADE;
CREATE #{unique}INDEX #{PGconn.quote_ident(index[:name])} ON #{PGconn.quote_ident(table.name)} (#{index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")});
EOF
    end
 
  end
  
  def write_indexes(table)
  end
  
  def write_constraints(table)
    table.foreign_keys.each do |key|
      @f << "ALTER TABLE #{PGconn.quote_ident(table.name)} ADD FOREIGN KEY (#{PGconn.quote_ident(key[:column])}) REFERENCES #{PGconn.quote_ident(key[:ref_table])}(#{PGconn.quote_ident(key[:ref_column])});\n"
    end
  end
  
  
  def write_contents(table, reader)
    @f << <<-EOF
--
-- Data for Name: #{table.name}; Type: TABLE DATA; Schema: public
--

COPY "#{table.name}" (#{table.columns.map {|column| PGconn.quote_ident(column[:name])}.join(", ")}) FROM stdin;
EOF
    
    reader.paginated_read(table, 1000) do |row, counter|
      process_row(table, row)
      @f << row.join("\t") + "\n"
    end
    @f << "\\.\n\n"
    #@f << "VACUUM FULL ANALYZE #{PGconn.quote_ident(table.name)};\n\n"
  end
  
  def close
    @f.close
  end
end

end