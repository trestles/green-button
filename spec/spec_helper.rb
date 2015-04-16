# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'bundler/setup'
Bundler.setup

require 'pvimpact-greenbutton'
require 'database_cleaner'

# Configure the gem
PVImpactGreenButton.configure do |config|
  config.db_url = 'postgres://localhost/pvimpact_greenbutton'
end

# Create DB
PVImpactGreenButton.create_db

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end