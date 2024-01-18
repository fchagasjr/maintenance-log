ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'

ActiveRecord::Base.establish_connection(:test)

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include ActiveRecord::TestFixtures
  include ActiveRecord::TestFixtures::ClassMethods

  class << self
    def fixtures(*fixture_set_names)
      self.fixture_path = 'test/fixtures/'
      super(*fixture_set_names)
    end
  end

  def app
    App
  end

  def login(user)
    user_id = user.id
    log_id = user.logged_log&.id
    env "rack.session", { :user_id => user_id, :log_id => log_id  }
  end

  def logout
    env "rack.session", { :user_id => nil, :log_id => nil }
  end
end
