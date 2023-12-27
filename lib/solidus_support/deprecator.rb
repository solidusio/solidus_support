# frozen_string_literal: true

module SolidusSupport
  class << self
    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new(Gem::Version.new('1.0'), 'SolidusSupport')
    end

    def solidus_deprecator
      Spree.solidus_gem_version >= Gem::Version.new('4.2') ? Spree.deprecator : Spree::Deprecation
    end
  end
end
