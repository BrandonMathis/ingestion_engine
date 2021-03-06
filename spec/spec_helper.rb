Bundler.require
require 'ingestion_engine'
require 'rspec/core'


ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "/tmp/ingestion_engine.sqlite"
)

connection = ActiveRecord::Base.connection

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:all) do
    connection.create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :username
      t.string :token
      t.string :full_name
    end
  end

  config.after(:all) do
    connection.drop_table :users
  end
end

class User < ActiveRecord::Base
  validates_presence_of :first_name
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
end
