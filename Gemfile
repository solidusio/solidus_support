# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus_core', github: 'solidusio/solidus', branch: branch

# Specify your gem's dependencies in solidus_support.gemspec
gemspec

gem 'solidus_dev_support', github: 'solidusio-contrib/solidus_dev_support'
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
