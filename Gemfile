ruby '2.1.7'
source 'https://rubygems.org'

gem 'rake', '~> 10.3'
gem 'mysql-pr', '~> 2.9'
gem 'postgres-pr', '~> 0.6'

platforms :jruby do
  gem 'activerecord'
  gem 'jdbc-postgres'
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
end

platforms :mri do
  gem 'pg', '~> 0.18'
end

gem 'test-unit'

group :test do
  gem 'jeweler', '~> 2.0'
end
