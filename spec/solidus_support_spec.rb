RSpec.describe SolidusSupport do
  describe '.payment_method_parent_class' do
    subject { described_class.payment_method_parent_class(credit_card: credit_card) }

    let(:credit_card) { nil }

    it { is_expected.to eq(Spree::PaymentMethod) }

    context 'with credit_card: true' do
      let(:credit_card) { true }

      before do
        expect(described_class).to receive(:solidus_gem_version) do
          Gem::Version.new(solidus_version)
        end
      end

      context 'For Solidus < 2.3' do
        let(:solidus_version) { '2.2.x' }
        it { is_expected.to eq(Spree::Gateway) }
      end

      context 'For Solidus >= 2.3' do
        let(:solidus_version) { '2.3.x' }
        it { is_expected.to eq(Spree::PaymentMethod::CreditCard) }
      end
    end
  end
end
