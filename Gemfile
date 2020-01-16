# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus_core', github: 'solidusio/solidus', branch: branch

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3'
end

gemspec
