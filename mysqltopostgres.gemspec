# frozen_string_literal: true

require_relative 'lib/mysql2psql/version'

Gem::Specification.new do |s|
  s.name        = 'mysqltopostgres'
  s.version     = Mysql2psql::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = [
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
  s.email       = 'paazmaya@yahoo.com'
  s.homepage    = 'https://github.com/maxlapshin/mysql2postgres'
  s.summary     = 'MySQL to PostgreSQL Data Translation'
  s.description = 'Translates MySQL -> PostgreSQL'
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")

  s.bindir      = 'exe'
  s.executables = ['mysqltopostgres']

  s.add_dependency 'mysql-pr',    '~> 2.9'
  s.add_dependency 'postgres-pr', '~> 0.6'

  if RUBY_PLATFORM == 'java'
    s.add_dependency('activerecord', ['~> 3.2'])
    s.add_dependency('jdbc-postgres', ['~> 9.4'])
    s.add_dependency('activerecord-jdbc-adapter', ['~> 1.2'])
    s.add_dependency('activerecord-jdbcpostgresql-adapter', ['~> 1.2'])
  end

  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'
end
