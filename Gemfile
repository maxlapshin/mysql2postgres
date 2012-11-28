source :rubygems

gem 'rake', '~> 10.0'
gem 'mysql-pr'
gem 'postgres-pr'

platforms :jruby do
  gem 'activerecord'
  gem 'jdbc-postgres'
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
end

platforms :mri_19 do
  gem 'pg'
end

gem 'test-unit'
