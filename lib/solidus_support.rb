require "solidus_support/version"
require "solidus_support/migration"
require "solidus_core"

module SolidusSupport
  class << self
    def solidus_gem_version
      if Spree.respond_to?(:solidus_gem_version)
        Spree.solidus_gem_version
      elsif Spree.respond_to?(:gem_version)
        # 1.1 doesn't have solidus_gem_version
        Gem::Version.new(Spree.solidus_version)
      else
        # 1.0 doesn't have gem_version
        Gem::Specification.detect{|x| x.name == "solidus_core" }.version
      end
    end

    def payment_source_parent_class
      if solidus_gem_version > Gem::Version.new('2.2.x')
        Spree::PaymentSource
      else
        Spree::Base
      end
    end

    def frontend_available?
      defined?(Spree::Frontend::Engine)
    end

    def backend_available?
      defined?(Spree::Backend::Engine)
    end

    def api_available?
      defined?(Spree::Api::Engine)
    end
  end
end
