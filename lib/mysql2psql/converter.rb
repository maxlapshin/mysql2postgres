class Converter
  attr_reader :reader, :writer, :options
  
  def initialize(reader, writer, options = {})
    @reader = reader
    @writer = writer
    @options = options
    @exclude_tables = options.exclude_tables([])
    @only_tables = options.only_tables(nil)
    @supress_data = options[:supress_data]
    @supress_ddl = options[:supress_ddl]
    @force_truncate = options[:force_truncate]
  end
  
  def convert
    _time1 = Time.now

    tables = reader.tables.
      reject {|table| @exclude_tables.include?(table.name)}.
      select {|table| @only_tables ? @only_tables.include?(table.name) : true}


    tables.each do |table|
      writer.write_table(table)
    end unless @supress_ddl
 
    _time2 = Time.now
    tables.each do |table|
      writer.truncate(table) if @force_truncate
      writer.write_contents(table, reader)
    end unless @supress_data
 
    _time3 = Time.now
    tables.each do |table|
      writer.write_indexes(table)
    end unless @supress_ddl
    tables.each do |table|
      writer.write_constraints(table)
    end unless @supress_ddl
 
 
    writer.close
    _time4 = Time.now
    puts "Table creation #{((_time2 - _time1) / 60).round} min, loading #{((_time3 - _time2) / 60).round} min, indexing #{((_time4 - _time3) / 60).round} min, total #{((_time4 - _time1) / 60).round} min"
  end
end
