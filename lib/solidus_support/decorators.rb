# SolidusSupport::Decorators is an efficient decorators loader that will extend the behavior of existing
# classes and modules without eagerly loading all of your decorators at each request.
#
# It nicely falls back to reloading them all when zeitwerk is not available, but will only load the decorators for a
# given base class when it can. This means that, on an average Solidus application, instead of loading 171 decorators
# and 61 base classes with all their dependency it will just load the ones needed by the current request, or, if
# starting a console, almost nothing.
#
# It will also prevent some nasty edge cases in which the use of `Rails.application.config.to_prepare(&…)` would do
# some things twice, messing up calls to super inside decorators (`to_prepare` is actually called twice under some
# circumstances).
#
# Migrating from Prependers:
#
#   require 'solidus_support/decorators'
#   SolidusSupport::Decorators.autoload_decorators(Rails.root.join("app/prependers/**/*.rb"), autoprepend: true) do |path|
#     relative = path.relative_path_from(Rails.root.join("app/prependers")) # models/spree/order/add_feature.rb
#     parts = relative.to_s.split(File::SEPARATOR)
#
#     {
#       # remove models/
#       # => "AcmeCorp::Spree::Order::AddFeature"
#       decorator: parts[1..-1].join("/").sub(/\.rb$/,'').camelize, # "AcmeCorp::Spree::Order::AddFeature"
#
#       # remove models/acme_corp/ and /add_feature.rb
#       # => "Spree::Order"
#       base: parts[2..-2].join("/").camelize, # "Spree::Order"
#     }
#   end
#
# Migrating from classic Solidus decorators
#
#   require 'solidus_support/decorators'
#   SolidusSupport::Decorators.autoload_decorators("#{Rails.root}/app/**/*_decorator.rb") do |path|
#     relative_path = path.relative_path_from(Rails.root.join("app/")) # models/acme_corp/order_decorator.rb
#     parts = relative_path.to_s.split(File::SEPARATOR)
#
#     {
#       # remove models/acme_corp/ and _decorator.rb, add spree/
#       # => "Spree::Order"
#       base: (["spree"] + parts[2..-1]).join("/").chomp("_decorator.rb").camelize,
#
#       # remove models/
#       # => "AcmeCorp::Spree::Order::AddFeature"
#       decorator: parts[1..-1].join("/").chomp(".rb").camelize,
#     }
#   end
#
# A more complex example with legacy mixed behaviors
#
#   require 'solidus_support/decorators'
#   SolidusSupport::Decorators.autoload_decorators("#{Rails.root}/app/**/*_decorator.rb", autoprepend: false) do |path|
#     case path.to_s
#     when /lockable_decorator/
#       nil # not a real decorator
#     when /carton_decorator/
#       {
#         base: "Spree::Carton",
#         decorator: "AcmeCorp::CartonDecorator",
#       }
#     when /devise_controller/
#       {
#         base: "DeviseController",
#         decorator: "AcmeCorp::DeviseControllerDecorator",
#       }
#     when /inventory_unit_finalizer/
#       {
#         base: "Spree::Stock::InventoryUnitsFinalizer",
#         decorator: "AcmeCorp::Stock::InventoryUnitFinalizerDecorator"
#       }
#     else
#       relative_path = path.relative_path_from(Rails.root.join("app/")) # models/acme_corp/order_decorator.rb
#       parts = relative_path.to_s.split(File::SEPARATOR)
#
#       {
#         base: (["spree"] + parts[2..-1]).join("/").chomp("_decorator.rb").camelize, # => "Spree::Order"
#         decorator: parts[1..-1].join("/").chomp(".rb").camelize, # => "AcmeCorp::OrderDecorator"
#       }
#     end
#   end
#
module SolidusSupport::Decorators
  extend self

  def autoload_decorators(glob, autoprepend: false)
    self.decorators_by_base = Hash.new { |h,k| h[k] = [] }
    self.autoprepend = autoprepend

    Dir[glob.to_s].map do |path|
      puts "<<< #{path}"
      result = yield(Pathname(path)) or next

      base = result.fetch(:base)
      decorator = result.fetch(:decorator)

      decorators_by_base[base] << decorator
    end

    if Rails.application.config.respond_to?(:autoloader) && Rails.application.config.autoloader == :zeitwerk
      setup_zeitwerk
    else
      setup_classic
    end
  end

  private

  attr_accessor :decorators_by_base, :autoprepend

  def decorate_base(base, decorators)
    puts "==> #{base} #{decorators.inspect}"
    # puts caller
    base_module = base.constantize

    decorators.each do |decorator|
      puts "--> #{decorator}"
      decorator_module = decorator.constantize

      if autoprepend
        base_module.prepend decorator_module
        if decorator_module.const_defined?(:ClassMethods)
          base_module.singleton_class.prepend decorator_module::ClassMethods
        end
      end
    end
  end

  def setup_classic
    _self = self # to_prepare runs in the context of the app

    Rails.application.config.to_prepare do
      _self.instance_eval do
        decorators_by_base.each do |base, decorators|
          decorate_base(base, decorators)
        end
      end
    end
  end

  def on_load_callback_installed
    @on_load_callback_installed ||= {}
  end

  def setup_zeitwerk
    loader = Rails.autoloaders.main

    decorators_by_base.keys.each do |base|
      next if on_load_callback_installed.key?(base)
      on_load_callback_installed[base] = true
      puts "==> on_load #{base}"

      loader.on_load(base) do
        # this needs to be dynamic because the call back is set up only
        # once, and the number of decorators may change
        decorate_base(base, decorators_by_base[base])
      end
    end
  end
end
