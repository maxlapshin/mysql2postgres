require 'rubygems'
require 'rake'

$LOAD_PATH.unshift('lib')
require 'mysql2psql/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mysql2psql"
    gem.version = Mysql2psql::Version::STRING
    gem.summary = %Q{Tool for converting mysql database to postgresql}
    gem.description = %Q{It can create postgresql dump from mysql database or directly load data from mysql to
    postgresql (at about 100 000 records per minute). Translates most data types and indexes.}
    gem.email = "gallagher.paul@gmail.com"
    gem.homepage = "http://github.com/tardate/mysql2postgresql"
    gem.authors = [
      "Max Lapshin <max@maxidoors.ru>",
      "Anton Ageev <anton@ageev.name>",
      "Samuel Tribehou <cracoucax@gmail.com>",
      "Marco Nenciarini <marco.nenciarini@devise.it>",
      "James Nobis <jnobis@jnobis.controldocs.com>",
      "quel <github@quelrod.net>",
      "Holger Amann <keeney@fehu.org>",
      "Maxim Dobriakov <closer.main@gmail.com>",
      "Michael Kimsal <mgkimsal@gmail.com>",
      "Jacob Coby <jcoby@portallabs.com>",
      "Neszt Tibor <neszt@tvnetwork.hu>",
      "Miroslav Kratochvil <exa.exa@gmail.com>",
      "Paul Gallagher <gallagher.paul@gmail.com>"
      ]
    gem.add_dependency "mysql", "= 2.8.1"
    gem.add_dependency "pg", "~> 0.10.0"
    gem.add_development_dependency "test-unit", ">= 2.1.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

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
