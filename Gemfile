# frozen_string_literal: true

source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus_core', github: 'solidusio/solidus', branch: branch

# Specify your gem's dependencies in solidus_support.gemspec
gemspec

gem 'solidus_extension_dev_tools', github: 'solidusio-contrib/solidus_extension_dev_tools'
gem 'sprockets', '~> 3'
gem 'sprockets-rails'

case ENV['DB']
when 'postgresql'
  gem 'pg'
when 'mysql'
  gem 'mysql2'
else
  gem 'sqlite3'
end
