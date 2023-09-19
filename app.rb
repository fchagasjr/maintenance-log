require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/assembly'
require_relative 'lib/entity'
require_relative 'lib/request_record'
require_relative 'lib/request_type'
require_relative 'lib/service_record'
require_relative 'lib/service_type'


class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Shared routes
  get "/" do
    @request_records = RequestRecord.all
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

  get "/assemblies/:id" do
    @assembly = Assembly.find(params[:id])
    "Page for #{@assembly.manufacturer}'s #{@assembly.description} under development"
  end

  post "/assembly" do
    @assembly = Assembly.new(description: params[:description],
                               manufacturer: params[:manufacturer],
                               model: params[:model])
    unless @assembly.valid?
      flash[:info] = @assembly.errors.full_messages
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
                         description: params[:description],
                         assembly_id: params[:assembly_id],
                         serial: params[:serial])

    unless @entity.valid?
      flash[:info] = @entity.errors.full_messages
      redirect "/entities/new"
    else
      @entity.save
      redirect "/entities"
    end
  end

  # Requests routes

  get "/request_records/new" do
    @request_types = RequestType.all
    @entities = Entity.all
    erb :"requests/new"
  end

  post "/request_record" do
    @request_record = RequestRecord.new(entity_id: params[:entity_id],
                                        request_type_id: params[:request_type_id],
                                        description: params[:description],
                                        )

    unless @request_record.valid?
      flash[:info] = @request_record.errors.full_messages
      redirect "/request_records/new"
    else
      @request_record.save
      redirect "/"
    end
  end

  # Service routes

  get "/service_records/new" do
    @request_types = RequestType.all
    @service_types = ServiceType.all
    @entities = Entity.all
    erb :"services/new"
  end

  post "/service_record" do
    @request_record = RequestRecord.new(entity_id: params[:entity_id],
                                        request_type_id: params[:request_type_id],
                                        description: params[:request_description],
                                        )

    unless @request_record.valid?
      flash[:info] = @request_record.errors.full_messages
      redirect "/service_records/new"
    else
      @request_record.save
      @service_record = @request_record.create_service_record(service_type_id: params[:service_type_id],
                                     description: params[:service_description],
                                     closed_at: params[:closed_at]
                                    )
      unless @service_record.valid?
        @request_record.destroy
        flash[:info] = @service_record.errors.full_messages
        redirect "/service_records/new"
      else
        redirect "/"
      end
    end
  end
end