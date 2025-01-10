# frozen_string_literal: true

module SolidusSupport
  module LegacyEventCompat
    # Compatibility for some event-driven operations
    module Bus
      # Publication of an event
      #
      # If extensions want to support the legacy sytem, they need to use a
      # compatible API. That means it's not possible to publish an instance as
      # event, which is something supported by Omnes but not the legacy adapter.
      # Instead, a payload can be given. E.g.:
      #
      # ```
      # SolidusSupport::LegacyEventCompat::Bus.publish(:foo, bar: :baz)
      # ```
      #
      # Legacy subscribers will receive an
      # `ActiveSupport::Notifications::Fanout`, while omnes subscribers will get
      # an `Omnes::UnstructuredEvent`. Both instances are compatible as they
      # implement a `#payload` method.
      #
      # @param event_name [Symbol]
      # @param payload [Hash<Symbol, Any>]
      def self.publish(event_name, **payload)
        if SolidusSupport::LegacyEventCompat.using_legacy?
          Spree::Event.fire(event_name, payload)
        else
          Spree::Bus.publish(event_name, **payload, caller_location: caller_locations(1)[0])
        end
      end
    end
  end
end
