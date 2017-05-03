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
  end
end
