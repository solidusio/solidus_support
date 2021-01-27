# frozen_string_literal: true

require 'solidus_support/version'
require 'solidus_support/migration'
require 'solidus_support/engine_extensions'
require 'solidus_core'

module SolidusSupport
  class << self
    def solidus_gem_version
      ActiveSupport::Deprecation.warn <<-WARN.squish, caller
        SolidusSupport.solidus_gem_version is deprecated and will be removed
        in solidus_support 1.0. Please use Spree.solidus_gem_version instead.
      WARN

      Spree.solidus_gem_version
    end

    def reset_spree_preferences_deprecated?
      first_version_without_reset = Gem::Requirement.new('>= 2.9')
      first_version_without_reset.satisfied_by?(Spree.solidus_gem_version)
    end

    def combined_first_and_last_name_in_address?
      versions_before_preference = Gem::Requirement.new('< 2.11.0')
      versions_after_preference = Gem::Requirement.new('>= 3.0.0.alpha')

      return false if versions_before_preference.satisfied_by?(Spree.solidus_gem_version)
      return true if versions_after_preference.satisfied_by?(Spree.solidus_gem_version)

      Spree::Config.use_combined_first_and_last_name_in_address
    end

    def new_gateway_code?
      first_version_with_new_gateway_code = Gem::Requirement.new('>= 2.3')
      first_version_with_new_gateway_code.satisfied_by?(Spree.solidus_gem_version)
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
