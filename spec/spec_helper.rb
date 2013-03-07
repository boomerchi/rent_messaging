require 'rubygems'
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require 'rails'
  require 'mongoid'
  require 'spork'
  require 'factory_girl'
  require 'ffaker'
  # require 'kaminari'
  require 'delorean'
  require 'concerned'

  # Configure Rails Envinronment
  ENV["RAILS_ENV"] = "test"

  # load support models
  Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each { |f| require f }
  Dir["#{File.dirname(__FILE__)}/support/models/**/*.rb"].each { |f| require f }

  require File.expand_path("../dummy/config/environment.rb",  __FILE__)

  require "rails/test_help"
  require "rspec/rails"

  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!

  # Configure capybara for integration testing
  require "capybara/rails"
  Capybara.default_driver   = :rack_test

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  # force require from engine models
  require 'account/system'
  require 'user/account/user'
  require 'user/account/landlord'
  require 'user/account/tenant'

  RSpec.configure do |config|
    # Remove this line if you don't want RSpec's should and should_not
    # methods or matchers
    require 'rspec/expectations'
    config.include RSpec::Matchers

    config.include FactoryGirl::Syntax::Methods

    # == Mock Framework
    config.mock_with :rspec

    config.include Mongoid::Matchers

    # Clean up the database
    require 'database_cleaner'
    config.before(:suite) do
      DatabaseCleaner[:mongoid].strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.clean
    end    
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  # FactoryGirl.reload
end
