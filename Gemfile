source :rubygems

gem 'mysql-pr', :git => 'git://github.com/ajokela/mysql-pr.git'
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
