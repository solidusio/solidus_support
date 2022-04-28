# frozen_string_literal: true

begin
  require "omnes"
rescue LoadError
end

module SolidusSupport
  module LegacyEventCompat
    # Compatibility for subscriber modules
    #
    # Thanks to this module, extensions can create legacy subscriber modules
    # (see {Spree::Event::Subscriber}) and translate them automatically to an
    # {Omnes::Subscriber}). E.g.:
    #
    # ```
    # module MyExtension
    #   module MySubscriber
    #     include Spree::Event::Subscriber
    #     include SolidusSupport::LegacyEventCompat::Subscriber
    #
    #     event_action :order_finalized
    #
    #     def order_finalized(event)
    #       event.payload[:order].do_something
    #     end
    #   end
    # end
    #
    # MyExtension::MySubscriber.omnes_subscriber.subscribe_to(Spree::Bus)
    # ```
    #
    # The generated omnes subscriptions will call the corresponding legacy
    # subscriber method with the omnes event. It'll compatible as long as the
    # omnes event responds to the `#payload` method (see
    # {Omnes::UnstructuredEvent}).
    module Subscriber
      # @api private
      ADAPTER = lambda do |legacy_subscriber, legacy_subscriber_method, _omnes_subscriber, omnes_event|
        legacy_subscriber.send(legacy_subscriber_method, omnes_event)
      end

      def self.included(legacy_subscriber)
        legacy_subscriber.define_singleton_method(:omnes_subscriber) do
          @omnes_subscriber ||= Class.new.include(::Omnes::Subscriber).tap do |subscriber|
            legacy_subscriber.event_actions.each do |(legacy_subscriber_method, event_name)|
              subscriber.handle(event_name.to_sym, with: ADAPTER.curry[legacy_subscriber, legacy_subscriber_method])
            end
          end.new
        end
      end
    end
  end
end
