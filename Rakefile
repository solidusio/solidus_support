# frozen_string_literal: true

require 'bundler'

begin
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'

  RuboCop::RakeTask.new
  RSpec::Core::RakeTask.new(:spec)

  task default: %i[spec]
end
