require 'spork'
require 'rake'
require 'factory_girl'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
  DUMMY_APP_ROOT=File.join(File.dirname(__FILE__), '/dummy')

  require 'active_support'
  require 'active_model'
  require 'active_record'
  require 'action_controller'

  # Configure Rails Envinronment
  ENV["RAILS_ENV"] = "spec"
  require File.expand_path(DUMMY_APP_ROOT + "/config/environment.rb",  __FILE__)

  ActiveRecord::Base.configurations = YAML::load(IO.read(DUMMY_APP_ROOT + "/config/database.yml"))
  ActiveRecord::Base.establish_connection(ENV["DB"] || "spec")
  ActiveRecord::Migration.verbose = false

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

  require 'rspec/rails'

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  FactoryGirl.find_definitions

  #We have to execute the migrations from dummy app directory
  Dir.chdir DUMMY_APP_ROOT
  `rake db:drop`
  Dir.chdir ENGINE_RAILS_ROOT

  #We have to execute the migrations from dummy app directory
  Dir.chdir DUMMY_APP_ROOT
  `rake db:migrate`
  Dir.chdir ENGINE_RAILS_ROOT

  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter "spec/"
  end
  #Need to explictly load the files in lib/ until we figure out how to
  #get rails to autoload them for spec like it used to...
  Dir[File.join(ENGINE_RAILS_ROOT, "lib/**/*.rb")].each {|f| load f}
end
