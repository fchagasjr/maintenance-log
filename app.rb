require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/equipment'
require_relative 'lib/assembly'
require_relative 'lib/entity'

class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Shared routes
  get "/" do
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end

  # Equipment routes
  get "/equipment" do
    @equipment = Equipment.all
    erb :equipment
  end

  get "/equipment/new" do
    erb :new_equipment
  end

  post "/equipment" do
    @equipment = Equipment.new(description: params[:description],
                               manufacturer: params[:manufacturer],
                               model: params[:model])
    unless @equipment.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/equipment/new"
    else
      @equipment.save
      redirect "/equipment"
    end
  end

  # Assemblies routes
  get "/assemblies" do
    @assemblies = Assembly.all
    erb :assemblies
  end

  get "/assemblies/new" do
    erb :new_assembly
  end

  post "/assembly" do
    @assembly = Assembly.new(description: params[:description])
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
    erb :entities
  end

  get "/entities/new" do
    @assemblies = Assembly.all
    @equipment = Equipment.all
    erb :new_entity
  end

  post "/entity" do
    assembly_id =
    @entity = Entity.new(id: params[:id],
                         description: params[:description])

    @entity.assembly_id = params[:assembly_id] if params[:assembly_id] != "null"
    @entity.equipment_id = params[:equipment_id] if params[:equipment_id] != "null"
    unless @entity.valid?
      flash[:info] = "Invalid data supplied. Information not saved to database"
      redirect "/entities/new"
    else
      @entity.save
      redirect "/entities"
    end
  end
end