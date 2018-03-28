# A basic feature_helper to be included as the starting point for extensions
#
# Can be required from an extension's spec/feature_helper.rb
#
#     require 'solidus_support/extension/feature_helper'
#

require 'solidus_support/extension/rails_helper'
require 'capybara'
require 'capybara-screenshot/rspec'

begin
  require 'capybara/poltergeist'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: true, timeout: 90)
  end
  Capybara.javascript_driver = :poltergeist
rescue LoadError
  @missing_poltergeist = true
end

begin
  require 'selenium/webdriver'
  Capybara.javascript_driver = :selenium_chrome_headless
rescue LoadError
  @missing_webdriver = true
end

if @missing_poltergeist && @missing_webdriver
  fail <<-WARN

Neither 'poltergeist' nor 'selenium-webdriver' are installed.
We cannot setup a Capybara driver for you.

Please install the 'poltergeist' or 'selenium-webdriver' gem

WARN
end

Capybara.default_max_wait_time = 10

require 'spree/testing_support/capybara_ext'

RSpec.configure do |config|
  config.when_first_matching_example_defined(type: :feature) do
    config.before :suite do
      # Preload assets
      if Rails.application.respond_to?(:precompiled_assets)
        Rails.application.precompiled_assets
      else
        # For older sprockets 2.x
        Rails.application.config.assets.precompile.each do |asset|
          Rails.application.assets.find_asset(asset)
        end
      end
    end
  end
end
