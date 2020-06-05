# frozen_string_literal: true

module SolidusSupport
  module EngineExtensions
    include ActiveSupport::Deprecation::DeprecatedConstantAccessor
    deprecate_constant 'Decorators', 'SolidusSupport::EngineExtensions'

    def self.included(engine)
      engine.extend ClassMethods

      engine.class_eval do
        solidus_decorators_root.glob('*') do |decorators_folder|
          config.autoload_paths += [decorators_folder]
        end

        config.to_prepare(&method(:activate))

        enable_solidus_engine_support('backend') if SolidusSupport.backend_available?
        enable_solidus_engine_support('frontend') if SolidusSupport.frontend_available?
        enable_solidus_engine_support('api') if SolidusSupport.api_available?
      end
    end

    module ClassMethods
      def activate
        load_solidus_decorators_from(solidus_decorators_root)
        load_solidus_subscribers_from(solidus_subscribers_root)
      end

      # Loads Solidus event subscriber files.
      #
      # This allows to add event subscribers to extensions without explicitly subscribing them,
      # similarly to what happens in Solidus core.
      def load_solidus_subscribers_from(path)
        if defined? Spree::Event
          path.glob("**/*_subscriber.rb") do |subscriber_path|
            require_dependency(subscriber_path)
          end
          Spree::Event.subscribers.each(&:subscribe!)
        end
      end

      # Loads decorator files.
      #
      # This is needed since they are never explicitly referenced in the application code and
      # won't be loaded by default. We need them to be executed regardless in order to decorate
      # existing classes.
      def load_solidus_decorators_from(path)
        path.glob('**/*.rb') do |decorator_path|
          require_dependency(decorator_path)
        end
      end

      private

      # Returns the root for this engine's decorators.
      #
      # @return [Path]
      def solidus_decorators_root
        root.join('app/decorators')
      end

      # Returns the root for this engine's Solidus event subscribers.
      #
      # @return [Path]
      def solidus_subscribers_root
        root.join("app/subscribers")
      end

      # Enables support for a Solidus engine.
      #
      # This will tell Rails to:
      #
      #   * add +lib/controllers/[engine]+ to the controller paths;
      #   * add +lib/views/[engine]+ to the view paths;
      #   * load the decorators in +lib/decorators/[engine]+.
      #
      # @see #load_solidus_decorators_from
      def enable_solidus_engine_support(engine)
        paths['app/controllers'] << "lib/controllers/#{engine}"
        paths['app/views'] << "lib/views/#{engine}"

        path = root.join("lib/decorators/#{engine}")

        config.autoload_paths += path.glob('*')

        engine_context = self
        config.to_prepare do
          engine_context.instance_eval do
            load_solidus_decorators_from(path)
          end
        end
      end
    end
  end
end
