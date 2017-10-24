# A basic rails_helper to be included as the starting point for extensions
#
# Can be required from an extension's spec/rails_helper.rb
#
#     require 'solidus_support/extension/rails_helper.rb'
#

require 'solidus_support/extension/spec_helper'

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'

require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/preferences'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  config.include Spree::TestingSupport::Preferences

  # Ensure Suite is set to use transactions for speed.
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  # Before each spec check if it is a Javascript test and switch between using database transactions or not where necessary.
  config.before :each do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start

    reset_spree_preferences
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end
end
