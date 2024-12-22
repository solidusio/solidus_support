# frozen_string_literal: true

RSpec.describe SolidusSupport::LegacyEventCompat::Bus do
  describe '#publish' do
    if SolidusSupport::LegacyEventCompat.using_legacy?
      it 'forwards to Spree::Event' do
        box = nil
        subscription = Spree::Event.subscribe(:foo) { |event| box = event.payload[:bar] }

        described_class.publish(:foo, bar: :baz)

        expect(box).to be(:baz)
      ensure
        Spree::Event.unsubscribe(subscription)
      end
    else
      it 'forwards to Spree::Bus' do
        box = nil
        Spree::Bus.register(:foo)
        subscription = Spree::Bus.subscribe(:foo) { |event| box = event.payload[:bar] }

        described_class.publish(:foo, bar: :baz)

        expect(box).to be(:baz)
      ensure
        Spree::Bus.unsubscribe(subscription)
        Spree::Bus.registry.unregister(:foo)
      end
    end
  end
end
