require 'active_record'
require 'database_cleaner'
require 'logger'
require 'shoulda/matchers'
require 'pry'
require 'model_settings'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), '../log/debug.log'))

ActiveRecord::Base.connection.create_table :model_settings do |t|
  t.string  :model_type, null: false
  t.integer :model_id, null: false
  t.string  :context
  t.string  :name, null: false
  t.string  :value
  t.timestamps
end
ActiveRecord::Base.connection.create_table :model_settings_user_tests, force: true do |t|
  t.integer :client_id
end
ActiveRecord::Base.connection.create_table :model_settings_client_tests, force: true do
end

require 'support/models'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end