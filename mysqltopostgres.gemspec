
Gem::Specification.new do |s|
  s.name = 'mysqltopostgres'
  s.version = '0.3.0'
  s.licenses = ['MIT']

  s.authors = [
    'Max Lapshin <max@maxidoors.ru>',
    'Anton Ageev <anton@ageev.name>',
    'Samuel Tribehou <cracoucax@gmail.com>',
    'Marco Nenciarini <marco.nenciarini@devise.it>',
    'James Nobis <jnobis@jnobis.controldocs.com>',
    'quel <github@quelrod.net>',
    'Holger Amann <keeney@fehu.org>',
    'Maxim Dobriakov <closer.main@gmail.com>',
    'Michael Kimsal <mgkimsal@gmail.com>',
    'Jacob Coby <jcoby@portallabs.com>',
    'Neszt Tibor <neszt@tvnetwork.hu>',
    'Miroslav Kratochvil <exa.exa@gmail.com>',
    'Paul Gallagher <gallagher.paul@gmail.com>',
    'Alex C Jokela <ajokela@umn.edu>',
    'Peter Clark <pclark@umn.edu>',
    'Juga Paazmaya <olavic@gmail.com>'
  ]
  s.date = '2015-11-26'
  s.default_executable = 'mysqltopostgres'
  s.description = 'Translates MySQL -> PostgreSQL'
  s.email = 'paazmaya@yahoo.com'
  s.executables = ['mysqltopostgres']

  s.files = [
    '.gitignore',
    'MIT-LICENSE',
    'README.md',
    'Rakefile',
    'bin/mysqltopostgres',
    'lib/mysqltopostgres.rb',
    'lib/mysql2psql/config.rb',
    'lib/mysql2psql/config_base.rb',
    'lib/mysql2psql/converter.rb',
    'lib/mysql2psql/connection.rb',
    'lib/mysql2psql/errors.rb',
    'lib/mysql2psql/mysql_reader.rb',
    'lib/mysql2psql/postgres_db_writer.rb',
    'lib/mysql2psql/postgres_file_writer.rb',
    'lib/mysql2psql/postgres_db_writer.rb',
    'lib/mysql2psql/postgres_writer.rb',
    'lib/mysql2psql/version.rb',
    'lib/mysql2psql/writer.rb',
    'mysqltopostgres.gemspec',
    'test/fixtures/config_all_options.yml',
    'test/fixtures/seed_integration_tests.sql',
    'test/integration/convert_to_db_test.rb',
    'test/integration/convert_to_file_test.rb',
    'test/integration/converter_test.rb',
    'test/integration/mysql_reader_base_test.rb',
    'test/integration/mysql_reader_test.rb',
    'test/integration/postgres_db_writer_base_test.rb',
    'test/lib/ext_test_unit.rb',
    'test/lib/test_helper.rb',
    'test/units/config_base_test.rb',
    'test/units/config_test.rb',
    'test/units/postgres_file_writer_test.rb'
  ]
  s.homepage = 'https://github.com/maxlapshin/mysql2postgres'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.rubygems_version = '2.4.0'
  s.summary = 'MySQL to PostgreSQL Data Translation'
  s.test_files = [
    'test/integration/convert_to_db_test.rb',
    'test/integration/convert_to_file_test.rb',
    'test/integration/converter_test.rb',
    'test/integration/mysql_reader_base_test.rb',
    'test/integration/mysql_reader_test.rb',
    'test/integration/postgres_db_writer_base_test.rb',
    'test/lib/ext_test_unit.rb',
    'test/lib/test_helper.rb',
    'test/units/config_base_test.rb',
    'test/units/config_test.rb',
    'test/units/postgres_file_writer_test.rb'
  ]

  s.add_dependency('mysql-pr', ['~> 2.9'])
  s.add_dependency('postgres-pr', ['~> 0.6'])
  s.add_dependency('test-unit', ['~> 2.1'])

  if RUBY_PLATFORM == 'java'
    s.add_dependency('activerecord', ['~> 3.2'])
    s.add_dependency('jdbc-postgres', ['~> 9.4'])
    s.add_dependency('activerecord-jdbc-adapter', ['~> 1.2'])
    s.add_dependency('activerecord-jdbcpostgresql-adapter', ['~> 1.2'])
  end

end
