# A basic spec_helper to be included as the starting point for extensions
#
# Can be required from an extension's spec/spec_helper.rb
#
#     require 'solidus_support/extension/spec_helper'
#

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.mock_with :rspec
  config.color = true

  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = 'random'

  Kernel.srand config.seed
end
