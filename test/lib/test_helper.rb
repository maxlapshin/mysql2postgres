require 'rubygems'
begin
  gem 'test-unit'
  require "test/unit"
rescue LoadError
  # assume using stdlib Test:Unit
  require 'test/unit'
end

require 'ext_test_unit'


