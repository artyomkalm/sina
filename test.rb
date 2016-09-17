ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative 'application.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Application" do

  it "should return json" do
    get '/greet?greet=1'
    last_response.headers['Content-Type'].must_equal 'application/json'
  end 

  it "should return the correct message as json" do
    get '/greet?greet=1'
    item = { status: 'ok', message: '1' }
    item.to_json.must_equal last_response.body
  end

end