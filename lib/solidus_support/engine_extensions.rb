# frozen_string_literal: true

module SolidusSupport
  module EngineExtensions
    # Matches e.g. "Spree::Order.prepend"
    DECORATED_CLASS_PATTERN = /(?<decorated_class>[A-Z][a-zA-Z:]+)(\.prepend[\s(])/

    include ActiveSupport::Deprecation::DeprecatedConstantAccessor
    deprecate_constant 'Decorators', 'SolidusSupport::EngineExtensions', deprecator: SolidusSupport.deprecator

    def self.included(engine)
      engine.extend ClassMethods

      engine.class_eval do
        solidus_decorators_root.glob('*') do |decorators_folder|
          config.autoload_paths += [decorators_folder]
        end

        config.to_prepare(&method(:activate))

        enable_solidus_engine_support('backend')
        enable_solidus_engine_support('frontend')
        enable_solidus_engine_support('api')
        enable_solidus_engine_support('admin')
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
        if SolidusSupport::LegacyEventCompat.using_legacy?
          path.glob("**/*_subscriber.rb") do |subscriber_path|
            require_dependency(subscriber_path)
          end

          if Spree::Event.respond_to?(:activate_all_subscribers)
            Spree::Event.activate_all_subscribers
          else
            Spree::Event.subscribers.each(&:subscribe!)
          end
        end
      end

      # Loads decorators.
      #
      # This is needed since they are never explicitly referenced in the application code and
      # won't be loaded by default. We need them to be executed whenever the decorated class is reloaded.
      def load_solidus_decorators_from(base_path)
        # This will be Zeitwerk.
        autoloader = Rails.autoloaders.main
        base_path.glob('**/*.rb') do |path|
          # Match all the classes that are prepended in the file
          matches = File.read(path).scan(DECORATED_CLASS_PATTERN).flatten

          # Don't do a thing if there's no prepending.
          next unless matches.present?

          # For each unique match, make sure we load the decorator when the base class is loaded
          matches.uniq.each do |decorated_class|
            # Zeitwerk tells us which constant it expects a file to provide.
            decorator_constant = autoloader.cpath_expected_at(path)

            # Sprinkle some debugging.
            Rails.logger.debug("Preparing to autoload #{decorated_class} with #{decorator_constant}")

            # If the class to be decorated has already been loaded, it won't be autoloaded later,
            # so we have to directly load the decorator.
            if Object.const_defined?(decorated_class)
              Rails.logger.debug("Loading #{decorator_constant} in order to modify #{decorated_class}")
              decorator_constant.constantize
            else
              # If the class has not been loaded, we can add a hook to load the decorator when it is.
              # Multiple hooks are no problem, as long as all decorators are namespaced appropriately.
              autoloader.on_load(decorated_class) do |base|
                Rails.logger.debug("Loading #{decorator_constant} in order to modify #{base}")
                decorator_constant.constantize
              end
            end
          end
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
        # In the past, view and controller paths of Solidus extensions were
        # added at extension loading time. As a result, if an extension
        # customizing a Solidus engine is loaded before that engine
        # (for example, the extension is declared before the `solidus_frontend`
        # engine in the `Gemfile`), then the extension's paths for that Solidus
        # engine wouldn't be loaded.

        # The initializer below runs before `initialize_cache` because
        # `initialize_cache` runs 1) after the Solidus engines have already
        # loaded BUT 2) before Rails has added the paths to `$LOAD_PATH`.
        # Normally, it would be sufficient to run the initializer below before
        # the `set_load_path` initializer. However, external gems such as
        # Deface may also change the load paths immediately before
        # `set_load_path`. To ensure that our extension paths are not affected
        # by those gems, we work around those gems by adding our paths before
        # `initialize_cache`, which is the Rails initializer called before
        # `set_load_path`.
        initializer "#{name}_#{engine}_paths", before: :initialize_cache do
          if SolidusSupport.send(:"#{engine}_available?")
            paths['app/controllers'] << "lib/controllers/#{engine}"
            paths['app/views'] << "lib/views/#{engine}"
          end
        end

        if SolidusSupport.send(:"#{engine}_available?")
          decorators_path = root.join("lib/decorators/#{engine}")
          controllers_path = root.join("lib/controllers/#{engine}")
          components_path = root.join("lib/components/#{engine}")
          config.autoload_paths += decorators_path.glob('*')
          config.autoload_paths << controllers_path if controllers_path.exist?
          config.autoload_paths << components_path if components_path.exist?

          engine_context = self
          config.to_prepare do
            engine_context.instance_eval do
              load_solidus_decorators_from(decorators_path)
            end
          end
        end
      end
    end
  end
end
