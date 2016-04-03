# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'factory_girl'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
