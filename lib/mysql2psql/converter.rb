class Mysql2psql

  class Converter
    attr_reader :reader, :writer, :options
    attr_reader :exclude_tables, :only_tables, :suppress_data, :suppress_ddl, :force_truncate, :preserve_order
  
    def initialize(reader, writer, options)
      @reader = reader
      @writer = writer
      @options = options
      @exclude_tables = options.exclude_tables([])
      @only_tables = options.only_tables(nil)
      @suppress_data = options.suppress_data(false)
      @suppress_ddl = options.suppress_ddl(false)
      @force_truncate = options.force_truncate(false)
      @preserve_order = options.preserve_order(false)
    end
  
    def convert
      _time1 = Time.now

      tables = reader.tables.
        reject {|table| @exclude_tables.include?(table.name)}.
        select {|table| @only_tables ? @only_tables.include?(table.name) : true}
        
      if @preserve_order

        reordered_tables = []

        @only_tables.each do |only_table|
          idx = tables.index {|table| table.name == only_table}
          reordered_tables << tables[idx]
        end

        tables = reordered_tables
        
      end

      tables.each do |table|
        writer.write_table(table)
      end unless @suppress_ddl
 
      _time2 = Time.now
      tables.each do |table|
        writer.truncate(table) if force_truncate && suppress_ddl
        writer.write_contents(table, reader)
      end unless @suppress_data
 
      _time3 = Time.now
      tables.each do |table|
        writer.write_indexes(table)
      end unless @suppress_ddl
      tables.each do |table|
        writer.write_constraints(table)
      end unless @suppress_ddl
 
 
      writer.close
      _time4 = Time.now
      puts "Table creation #{((_time2 - _time1) / 60).round} min, loading #{((_time3 - _time2) / 60).round} min, indexing #{((_time4 - _time3) / 60).round} min, total #{((_time4 - _time1) / 60).round} min"
      return 0
    rescue => e
      $stderr.puts "Mysql2psql: conversion failed: #{e.to_s}"
      return -1
    end
  end

end
