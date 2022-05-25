# frozen_string_literal: true

require 'solidus_support/legacy_event_compat/bus'
require 'solidus_support/legacy_event_compat/subscriber'

module SolidusSupport
  # Compatibility middleman for {Spree::Event} and {Spree::Bus}
  #
  # Solidus v3.2 changed to use [Omnes](https://github.com/nebulab/omnes) as the
  # backbone for event-driven behavior (see {Spree::Bus}) by default. Before
  # that, a custom adapter based on {ActiveSupport::Notifications} was used (see
  # {Spree::Event}. Both systems are still supported on v3.2.
  #
  # This module provides compatibility support so that extensions can easily
  # target both systems regardless of the underlying circumstances:
  #
  # - Solidus v3.2 with the new system.
  # - Solidus v3.2 with the legacy system.
  # - Solidus v2.9 to v3.1, when only {Spree::Event} existed.
  # - Possible future versions of Solidus, whether the legacy system is
  # eventually removed or not.
  module LegacyEventCompat
    # Returns whether the application is using the legacy event system
    #
    # @return [Boolean]
    def self.using_legacy?
      legacy_present? &&
        (legacy_alone? ||
         legacy_chosen?)
    end

    def self.legacy_present?
      defined?(Spree::Event)
    end
    private_class_method :legacy_present?

    def self.legacy_alone?
      !Spree::Config.respond_to?(:use_legacy_events)
    end
    private_class_method :legacy_alone?

    def self.legacy_chosen?
      Spree::Config.use_legacy_events
    end
    private_class_method :legacy_chosen?
  end
end
