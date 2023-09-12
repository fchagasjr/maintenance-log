require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/assembly'
require_relative 'lib/entity'
require_relative 'lib/log_entry'

class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Shared routes
  get "/" do
    @log_entries = LogEntry.all
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end

  # Assembly routes
  get "/assemblies" do
    @assemblies = Assembly.all
    erb :"assemblies/index"
  end

  get "/assemblies/new" do
    erb :"assemblies/new"
  end

  post "/assembly" do
    @assembly = Assembly.new(description: params[:description],
                               manufacturer: params[:manufacturer],
                               model: params[:model])
    unless @assembly.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/assemblies/new"
    else
      @assembly.save
      redirect "/assemblies"
    end
  end

  # Entities routes
  get "/entities" do
    @entities = Entity.all
    erb :"entities/index"
  end

  get "/entities/new" do
    @assemblies = Assembly.all
    erb :"entities/new"
  end

  get "/entities/:id" do
    @entity = Entity.find(params["id"].to_s)
    erb :"entities/show"
  end


  post "/entity" do
    @entity = Entity.new(id: params[:id],
                         description: params[:description])

    @entity.assembly_id = params[:assembly_id] if params[:assembly_id] != "null"
    unless @entity.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/entities/new"
    else
      @entity.save
      redirect "/entities"
    end
  end
end