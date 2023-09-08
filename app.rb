require 'sinatra'
require 'sinatra/activerecord'

class App < Sinatra::Base
  get "/" do
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end
end