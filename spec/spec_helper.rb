ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require "rack_session_access"
require "rack_session_access/capybara"
require 'database_cleaner'
require 'capybara/rspec'

require_relative File.join('..', 'app')

Capybara.app = POSApplication;

Capybara.app.configure do |config|
  config.use RackSessionAccess::Middleware
end

RSpec.configure do |config|
  include Rack::Test::Methods

  config.color = true
  config.tty = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def app
    POSApplication
  end

end
