require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/assembly'
require_relative 'lib/group'
require_relative 'lib/entity'

class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Shared routes
  get "/" do
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end

  # Assembly routes
  get "/assemblies" do
    @assemblies = Assembly.all
    erb :assemblies
  end

  get "/assemblies/new" do
    erb :new_assembly
  end

  post "/assembly" do
    @assembly = Assembly.new(description: params[:description],
                               manufacturer: params[:manufacturer],
                               model: params[:model])
    unless @assembly.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/assemblies/new"
    else
      @equipment.save
      redirect "/assemblies"
    end
  end

  # Group routes
  get "/groups" do
    @groups = Group.all
    erb :groups
  end

  get "/groups/new" do
    erb :new_group
  end

  post "/group" do
    @group = Group.new(description: params[:description])
    unless @group.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/groups/new"
    else
      @group.save
      redirect "/groups"
    end
  end

  # Entities routes
  get "/entities" do
    @entities = Entity.all
    erb :entities
  end

  get "/entities/new" do
    @groups = Group.all
    @assemblies = Assembly.all
    erb :new_entity
  end

  post "/entity" do
    @entity = Entity.new(id: params[:id],
                         description: params[:description])

    @entity.group_id = params[:group_id] if params[:group_id] != "null"
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