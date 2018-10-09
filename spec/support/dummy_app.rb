ENV['RAILS_ENV'] = 'test'
ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

Bundler.setup

require 'rails'
require 'solidus_core'

Bundler.require(:default, :test)

module DummyApp
  class Application < ::Rails::Application
    config.eager_load               = false
    config.paths["config/database"] = File.expand_path('../dummy_app/database.yml', __FILE__)
  end
end

DummyApp::Application.initialize!
