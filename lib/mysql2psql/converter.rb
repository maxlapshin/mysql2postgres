class Mysql2psql

  class Converter
    attr_reader :reader, :writer, :options
    attr_reader :exclude_tables, :only_tables, :suppress_data, :suppress_ddl, :supress_sequence_update, :force_truncate, :suppress_indexes

    def initialize(reader, writer, options)
      @reader = reader
      @writer = writer
      @options = options
      @exclude_tables = options.exclude_tables([])
      @only_tables = options.only_tables(nil)
      @suppress_data = options.suppress_data(false)
      @suppress_ddl = options.suppress_ddl(false)
      @supress_sequence_update = options.supress_sequence_update(false)
      @suppress_indexes = options.suppress_indexes(false)
      @force_truncate = options.force_truncate(false)
      @use_timezones = options.use_timezones(false)
    end

    def convert
      _time1 = Time.now

      tables = reader.tables.
        reject {|table| @exclude_tables.include?(table.name)}.
        select {|table| @only_tables ? @only_tables.include?(table.name) : true}

      tables.each do |table|
        writer.write_sequence_update(table, options)
      end if !(@suppress_sequence_update && @suppress_ddl)

      tables.each do |table|
        writer.write_table(table, {:use_timezones => @use_timezones})
      end unless @suppress_ddl
 
      _time2 = Time.now
      tables.each do |table|
        writer.truncate(table) if force_truncate && !suppress_ddl
        writer.write_contents(table, reader)
      end unless @suppress_data

      _time3 = Time.now
      tables.each do |table|
        writer.write_indexes(table) unless @suppress_indexes
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
