require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "active_resource/railtie"

Bundler.require
require "rent_messaging"
require "sprockets/railtie"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    # config.action_view.javascript_expansions[:cdn] = %w(https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js rails)

    # config.paths.public = File.expand_path(File.join(Rails.root, '..', '..', 'lib', 'generators', 'governor', 'templates', 'assets'))
    # config.paths.public.images = File.expand_path(File.join(Rails.root, '..', '..', 'lib', 'generators', 'governor', 'templates', 'assets', 'images'))
    # config.paths.public.javascripts = File.expand_path(File.join(Rails.root, '..', '..', 'lib', 'generators', 'governor', 'templates', 'assets', 'javascripts'))
    # config.paths.public.stylesheets = File.expand_path(File.join(Rails.root, '..', '..', 'lib', 'generators', 'governor', 'templates', 'assets', 'stylesheets'))

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en # :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
