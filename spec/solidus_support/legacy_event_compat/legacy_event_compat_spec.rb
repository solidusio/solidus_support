# frozen_string_literal: true

require 'omnes'

RSpec.describe SolidusSupport::LegacyEventCompat::Subscriber do
  subject { Module.new.include(Spree::Event::Subscriber).include(described_class) }

  describe '#omnes_subscriber' do
    it 'returns an Omnes::Subscriber' do
      subject.module_eval do
        event_action :foo

        def foo(_event); end
      end

      expect(subject.omnes_subscriber.is_a?(Omnes::Subscriber)).to be(true)
    end

    it 'adds single-event definitions matching legacy event actions' do
      subject.module_eval do
        event_action :foo

        def foo(_event); end
      end
      bus = Omnes::Bus.new
      bus.register(:foo)

      subscriptions = subject.omnes_subscriber.subscribe_to(bus)

      event = Struct.new(:omnes_event_name).new(:foo)
      expect(subscriptions.first.matches?(event)).to be(true)
    end

    it 'coerces event names given as Strings' do
      subject.module_eval do
        event_action 'foo'

        def foo(_event); end
      end
      bus = Omnes::Bus.new
      bus.register(:foo)

      subscriptions = subject.omnes_subscriber.subscribe_to(bus)

      event = Struct.new(:omnes_event_name).new(:foo)
      expect(subscriptions.first.matches?(event)).to be(true)
    end

    it 'executes legacy event action methods as handlers with the omnes event' do
      subject.module_eval do
        event_action :foo

        def foo(event)
          event[:bar]
        end
      end
      bus = Omnes::Bus.new
      bus.register(:foo)

      subscriptions = subject.omnes_subscriber.subscribe_to(bus)

      expect(
        bus.publish(:foo, bar: :baz).executions.first.result
      ).to be(:baz)
    end

    it 'distingish when event name is given explicitly' do
      subject.module_eval do
        event_action :foo, event_name: :bar

        def foo(_event)
          :bar
        end
      end
      bus = Omnes::Bus.new
      bus.register(:bar)

      subscriptions = subject.omnes_subscriber.subscribe_to(bus)

      expect(
        bus.publish(:bar).executions.first.result
      ).to be(:bar)
    end

    it "returns the same omnes subscriber instance if called again" do
      expect(subject.omnes_subscriber).to be(subject.omnes_subscriber)
    end

    it "doesn't fail when no event action has been defined" do
      expect { subject.omnes_subscriber }.not_to raise_error
    end
  end
end
