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

    def new_gateway_code?
      first_version_with_new_gateway_code = Gem::Requirement.new('>= 2.3')
      first_version_with_new_gateway_code.satisfied_by?(solidus_gem_version)
    end

    def payment_source_parent_class
      if new_gateway_code?
        Spree::PaymentSource
      else
        Spree::Base
      end
    end

    def payment_method_parent_class(credit_card: false)
      if new_gateway_code?
        if credit_card
          Spree::PaymentMethod::CreditCard
        else
          Spree::PaymentMethod
        end
      else
        Spree::Gateway
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
