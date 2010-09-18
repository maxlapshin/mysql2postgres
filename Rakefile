require 'rubygems'
require 'rake'

$LOAD_PATH.unshift('lib')
require 'mysql2psql/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mysql2psql"
    gem.version = Mysql2psql::Version::STRING
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "gallagher.paul@gmail.com"
    gem.homepage = "http://github.com/tardate/mysql2postgresql"
    gem.authors = ["Paul Gallagher"]
    gem.add_dependency "mysql", "= 2.8.1"
    gem.add_dependency "pg", "= 0.9.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
namespace :test do
  
desc "Seed the test database (mysql db=mysql2psql_test user=mysql2psql)"
task :seed_database do
begin
  seedfilepath = "#{File.dirname(__FILE__)}/test/fixtures/seed_integration_tests.sql"
  rc=system("mysql -umysql2psql mysql2psql_test < #{seedfilepath}")
  raise StandardError unless rc
rescue
  raise StandardError.new("Failed to seed integration test db. See README for setup requirements.")
end
end

Rake::TestTask.new(:units) do |test|
  test.libs << 'lib' << 'test/lib'
  test.pattern = 'test/units/*test.rb'
  test.verbose = true
end

Rake::TestTask.new(:integration) do |test|
  Rake::Task['test:seed_database'].invoke
  test.libs << 'lib' << 'test/lib'
  test.pattern = 'test/integration/*test.rb'
  test.verbose = true
end
end

desc "Run all tests"
task :test do
  Rake::Task['test:units'].invoke
  Rake::Task['test:integration'].invoke
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = Mysql2psql::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mysql2psql #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
