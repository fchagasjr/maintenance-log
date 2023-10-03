require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/user'
require_relative 'lib/assembly'
require_relative 'lib/entity'
require_relative 'lib/request_record'
require_relative 'lib/request_type'
require_relative 'lib/service_record'
require_relative 'lib/service_type'


class App < Sinatra::Base
  helpers do
    def logged_in?
      !current_user.nil?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  enable :sessions
  register Sinatra::Flash

  # Redirect not logged users from unauthorized pages
  before /\/(?!(login|logout|signup)).*/ do
    unless logged_in?
      flash[:info] = "You need to login first!"
      redirect "/login"
    end
  end

  # Shared routes

  get "/" do
    @request_records = RequestRecord.all
    @now = Time.now(in: "-04:00") #Time now UTC -04:00
    erb :index
  end

  # Users

  get '/login' do
    erb :"users/login"
  end

  post '/login' do
    @user = User.find_by(email: params[:email])

    if !@user.nil? && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:info] = "Welcome back, #{current_user.first_name}!"
      redirect "/"
    else
      flash[:info] = "Email and password combination not matching"
      redirect "/login"
    end
  end

  get '/logout' do
    session[:user_id] = nil
    redirect "/login"
  end

  get '/signup' do
    erb :"users/signup"
  end

  post '/signup' do
    @user = User.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if @user.save
      session[:user_id] = @user.id
      flash[:info] = "Welcome, #{current_user.first_name}!"
      redirect '/'
    else
     flash[:info] = @user.errors.full_messages
     redirect "/signup"
    end
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
    erb :"assemblies/show"
  end

  post "/assembly" do
    unless current_user.admin?
      flash[:info] = "Operation cancelled! Only administrators can perform this action"
      redirect back
    end
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
    unless current_user.admin?
    flash[:info] = "Operation cancelled! Only administrators can perform this action"
    redirect back
    end
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

  get "/request_records/:id" do
    @request_record = RequestRecord.find(params[:id])
    erb :"requests/show"
  end

  post "/request_record" do
    unless current_user.active?
      flash[:info] = "Operation cancelled! Only active users can perform this action"
      redirect "/"
    end
    @request_record = RequestRecord.new(entity_id: params[:entity_id],
                                        request_type_id: params[:request_type_id],
                                        description: params[:description],
                                        user_id: current_user.id
                                        )

    unless @request_record.valid?
      flash[:info] = @request_record.errors.full_messages
      redirect "/request_records/new"
    else
      @request_record.save
      redirect "/request_records/#{@request_record.id}"
    end
  end

  # Service routes

  get "/service_records/new" do
    @request_record = RequestRecord.find(params[:request_record_id])
    @service_types = ServiceType.all
    erb :"services/new"
  end

  post "/service_record" do
    unless current_user.active?
      flash[:info] = "Operation cancelled! Only active users can perform this action"
      redirect back
    end
    @request_record = RequestRecord.find(params[:request_record_id])
    @service_record = @request_record
                        .create_service_record(service_type_id: params[:service_type_id],
                                               description: params[:service_description],
                                               closed_at: params[:closed_at],
                                               user_id: current_user.id
                                               )
    flash[:info] = @service_record.errors.full_messages unless @service_record.valid?
    redirect "/request_records/#{@request_record.id}"
  end

  get "/service_record/edit/:id" do
    @service_types = ServiceType.all
    @service_record = ServiceRecord.find(params[:id])
    erb :"services/edit"
  end

  post "/service_record/edit/:id" do
    unless current_user.active?
      flash[:info] = "Operation cancelled! Only active users can perform this action"
      redirect back
    end
    @service_record = ServiceRecord.find(params[:id])
    @service_record.update(service_type_id: params[:service_type_id],
                           description: params[:service_description],
                           closed_at: params[:closed_at],
                           user_id: current_user.id
                           )
    redirect "/request_records/#{@service_record.request_record.id}"
  end
end
