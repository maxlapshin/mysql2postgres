ruby '1.9.3'
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

platforms :mri_19 do
  gem 'pg', '~> 0.17'
end

gem 'test-unit'


