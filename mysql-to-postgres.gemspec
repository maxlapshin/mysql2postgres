
Gem::Specification.new do |s|
  s.name = %q{mysql-to-postgres}
  s.version = "0.2.10"

  s.authors = ["Max Lapshin <max@maxidoors.ru>", "Anton Ageev <anton@ageev.name>", "Samuel Tribehou <cracoucax@gmail.com>", "Marco Nenciarini <marco.nenciarini@devise.it>", "James Nobis <jnobis@jnobis.controldocs.com>", "quel <github@quelrod.net>", "Holger Amann <keeney@fehu.org>", "Maxim Dobriakov <closer.main@gmail.com>", "Michael Kimsal <mgkimsal@gmail.com>", "Jacob Coby <jcoby@portallabs.com>", "Neszt Tibor <neszt@tvnetwork.hu>", "Miroslav Kratochvil <exa.exa@gmail.com>", "Paul Gallagher <gallagher.paul@gmail.com>", "Alex C Jokela <ajokela@umn.edu>"]
  s.date = %q{2010-09-19}
  s.default_executable = %q{mysql-to-postgres}
  s.description = %q{Translates MySQL -> PostgreSQL via pure ruby MySQL}
  s.email = %q{alex@camulus.com}
  s.executables = ["mysql-to-postgres"]

  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README.md",
     "Rakefile",
     "bin/mysql-to-postgres",
     "lib/mysql2psql.rb",
     "lib/mysql2psql/config.rb",
     "lib/mysql2psql/config_base.rb",
     "lib/mysql2psql/converter.rb",
     "lib/mysql2psql/errors.rb",
     "lib/mysql2psql/mysql_reader.rb",
     "lib/mysql2psql/postgres_db_writer.rb",
     "lib/mysql2psql/postgres_file_writer.rb",
     "lib/mysql2psql/postgres_db_writer.rb",
     "lib/mysql2psql/postgres_writer.rb",
     "lib/mysql2psql/version.rb",
     "lib/mysql2psql/writer.rb",
     "mysql-to-postgres.gemspec",
     "test/fixtures/config_all_options.yml",
     "test/fixtures/seed_integration_tests.sql",
     "test/integration/convert_to_db_test.rb",
     "test/integration/convert_to_file_test.rb",
     "test/integration/converter_test.rb",
     "test/integration/mysql_reader_base_test.rb",
     "test/integration/mysql_reader_test.rb",
     "test/integration/postgres_db_writer_base_test.rb",
     "test/lib/ext_test_unit.rb",
     "test/lib/test_helper.rb",
     "test/units/config_base_test.rb",
     "test/units/config_test.rb",
     "test/units/postgres_file_writer_test.rb"
  ]
  s.homepage = %q{https://github.com/ajokela/mysql-to-postgres}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Tool for converting mysql database to postgresql}
  s.test_files = [
    "test/integration/convert_to_db_test.rb",
     "test/integration/convert_to_file_test.rb",
     "test/integration/converter_test.rb",
     "test/integration/mysql_reader_base_test.rb",
     "test/integration/mysql_reader_test.rb",
     "test/integration/postgres_db_writer_base_test.rb",
     "test/lib/ext_test_unit.rb",
     "test/lib/test_helper.rb",
     "test/units/config_base_test.rb",
     "test/units/config_test.rb",
     "test/units/postgres_file_writer_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mysql-pr>, [">= 2.9.10"])
      s.add_runtime_dependency(%q<postgres-pr>, ["= 0.6.3"])
      s.add_development_dependency(%q<test-unit>, [">= 2.1.1"])
    else
      s.add_dependency(%q<mysql-pr>, ["= 2.9.9"])
      s.add_dependency(%q<postgres-pr>, ["= 0.6.3"])
      s.add_dependency(%q<test-unit>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<mysql-pr>, [">= 2.9.10"])
    s.add_dependency(%q<postgres-pr>, ["= 0.6.3"])
    s.add_dependency(%q<test-unit>, [">= 2.1.1"])
  end
end

