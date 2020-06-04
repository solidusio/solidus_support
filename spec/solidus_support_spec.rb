# frozen_string_literal: true

RSpec.describe SolidusSupport do
  describe '.payment_method_parent_class' do
    subject { described_class.payment_method_parent_class(credit_card: credit_card) }

    let(:credit_card) { nil }

    before do
      allow(Spree).to receive(:solidus_gem_version) do
        Gem::Version.new(solidus_version)
      end
    end

    context 'with Solidus < 2.3' do
      let(:solidus_version) { '2.2.1' }

      it { is_expected.to eq(Spree::Gateway) }
    end

    context 'with Solidus >= 2.3' do
      let(:solidus_version) { '2.3.1' }

      it { is_expected.to eq(Spree::PaymentMethod) }
    end

    # rubocop:disable RSpec/NestedGroups
    context 'with credit_card: true' do
      let(:credit_card) { true }

      context 'with Solidus < 2.3' do
        let(:solidus_version) { '2.2.1' }

        it { is_expected.to eq(Spree::Gateway) }
      end

      context 'with Solidus >= 2.3' do
        let(:solidus_version) { '2.3.1' }

        it { is_expected.to eq(Spree::PaymentMethod::CreditCard) }
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end
end
