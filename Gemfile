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

# There is an issue with Sprockets 4 not accepting a custom path for
# the assets manifest, which doesn't play well with in-memory dummy
# apps such as the one we use in this gem.

# A fix was provided for sprockets-rails[1] but it was not accepted
# yet.

# [1]: rails/sprockets-rails#446
#
# Please do not remove this line until we have a solution.
gem 'sprockets', '~> 3'
