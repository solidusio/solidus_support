# frozen_string_literal: true

module SolidusSupport
  module Migration
    def self.[](version)
      SolidusSupport.deprecator.warn(
        "SolidusSupport::Migration[#{version}] is deprecated. Please use ActiveRecord::Migration[#{version}] instead."
      )
      ActiveRecord::Migration[version]
    end
  end
end
