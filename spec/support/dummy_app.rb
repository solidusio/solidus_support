# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

Bundler.setup

require 'rails'
require 'solidus_core'

Bundler.require(:default, :test)

module DummyApp
  class Application < ::Rails::Application
    config.eager_load               = false
    config.paths['config/database'] = File.expand_path('dummy_app/database.yml', __dir__)
    if ActiveRecord::VERSION::MAJOR >= 7
      config.active_record.legacy_connection_handling = false
    end
  end
end

Spree::Config.load_defaults Spree::VERSION

DummyApp::Application.initialize!
