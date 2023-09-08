require 'sinatra'
require 'sinatra/activerecord'
require_relative 'lib/equipment'
require_relative 'lib/assembly'

class App < Sinatra::Base
  get "/" do
    @assemblies = Assembly.all
    @equipment = Equipment.all
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end

  post "/equipment" do
    description = params[:description]
    model = params[:model]
    manufacturer = params[:manufacturer]
    @equipment = Equipment.new(description: description, manufacturer: manufacturer, model:model)
    @equipment.save
    redirect "/"
  end

  post "/assemblies" do
    description = params[:description]
    @assembly = Assembly.new(description: description)
    @assembly.save
    redirect "/"
  end

end