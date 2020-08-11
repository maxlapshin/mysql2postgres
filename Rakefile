require 'rubygems'
require 'rake'

require_relative 'lib/mysql2psql/version'

require 'rake/testtask'
namespace :test do
  Rake::TestTask.new(:units) do |test|
    test.libs << 'lib' << 'test/lib'
    test.pattern = 'test/units/*test.rb'
    test.verbose = true
  end

  Rake::TestTask.new(:integration) do |test|
    test.libs << 'lib' << 'test/lib'
    test.pattern = 'test/integration/*test.rb'
    test.verbose = true
  end
end

desc 'Run all tests'
task :test do
  Rake::Task['test:units'].invoke
  #Rake::Task['test:integration'].invoke
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
    abort 'RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov'
  end
end

task default: :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = Mysql2psql::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mysql2psql #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
