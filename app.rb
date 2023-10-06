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
    def check_permission(status)
      unless current_user.send(:"#{status}?")
        flash[:info] = "Operation cancelled! Only #{status} users can perform this action"
        redirect back
      end
    end

    def login(user)
      session[:user_id] = user.id
    end

    def logout
      session[:user_id] = nil
    end

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
      flash.now[:info] = "You need to login first!"
      halt erb :"users/login"
    end
  end

  # Shared routes

  not_found do
    flash[:alert] = "Page \"#{request.path}\" cannot be found!"
    redirect "/"
  end

  get "/" do
    @request_records = RequestRecord.all
    erb :index
  end

  # Users routes

  get '/login' do
    if logged_in?
      redirect "/"
    else
      erb :"users/login"
    end
  end

  post '/login' do
    @user = User.find_by(email: params[:email])
    if !@user.nil? && @user.authenticate(params[:password])
      login(@user)
      flash[:info] = "Welcome back, #{current_user.first_name}!"
      redirect back
    else
      flash[:alert] = "Email and password combination not matching"
      redirect "/login"
    end
  end

  get '/logout' do
    logout
    redirect "/login"
  end

  get '/signup' do
    if logged_in?
      redirect "/"
    else
      erb :"users/signup"
    end
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
      login(@user)
      flash[:info] = "Welcome, #{current_user.first_name}!"
      redirect '/'
    else
     flash[:alert] = @user.errors.full_messages
     redirect "/signup"
    end
  end

  get "/users/account" do
    erb :"users/show"
  end

  get "/users/edit" do
    erb :"users/edit"
  end

  post "/users/edit" do
    current_user.update(first_name: params[:first_name],
                        last_name: params[:last_name],
                        email: params[:email])
    if current_user.valid?
      flash[:info] = "User account updated"
      redirect "/"
    else
      flash[:alert] = current_user.errors.full_messages
      current_user.reload
      redirect "/users/edit"
    end
  end

  # Assembly routes

  get "/assemblies" do
    @assemblies = Assembly.all
    erb :"assemblies/index"
  end

  get "/assemblies/new" do
    check_permission(:admin)
    erb :"assemblies/new"
  end

  get "/assemblies/:id" do
    @assembly = Assembly.find(params[:id])
    erb :"assemblies/show"
  end

  post "/assemblies" do
    check_permission(:admin)
    @assembly = Assembly.new(description: params[:description],
                               manufacturer: params[:manufacturer],
                               model: params[:model])
    unless @assembly.valid?
      flash[:alert] = @assembly.errors.full_messages
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

  post "/entities" do
    check_permission(:admin)
    @entity = Entity.new(id: params[:id],
                         description: params[:description],
                         assembly_id: params[:assembly_id],
                         serial: params[:serial])

    unless @entity.valid?
      flash[:alert] = @entity.errors.full_messages
      redirect "/entities/new"
    else
      @entity.save
      redirect "/entities"
    end
  end

  # Requests routes

  get "/request_records/new" do
    check_permission(:active)
    @request_types = RequestType.all
    @entities = Entity.all
    erb :"requests/new"
  end

  get "/request_records/:id" do
    @request_record = RequestRecord.find(params[:id])
    erb :"requests/show"
  end

  post "/request_records" do
    check_permission(:active)
    @request_record = RequestRecord.new(entity_id: params[:entity_id],
                                        request_type_id: params[:request_type_id],
                                        description: params[:description],
                                        user_id: current_user.id
                                        )

    unless @request_record.valid?
      flash[:alert] = @request_record.errors.full_messages
      redirect "/request_records/new"
    else
      @request_record.save
      redirect "/request_records/#{@request_record.id}"
    end
  end

  get "/request_records/edit/:id" do
    @entities = Entity.all
    @request_types = RequestType.all
    @request_record = RequestRecord.find(params[:id])
    erb :"requests/edit"
  end

  post "/request_records/edit/:id" do
    check_permission(:active)
    @request_record = RequestRecord.find(params[:id])
    @request_record.update(entity_id: params[:entity_id],
                           request_type_id: params[:request_type_id],
                           description: params[:request_description],
                           user_id: current_user.id
                           )
    flash[:alert] = @request_record.errors.full_messages  unless @request_record.valid?
    redirect "/request_records/#{@request_record.id}"
  end

  # Service routes

  get "/service_records/new" do
    @request_record = RequestRecord.find(params[:request_record_id])
    @service_types = ServiceType.all
    erb :"services/new"
  end

  post "/service_records" do
    check_permission(:active)
    @request_record = RequestRecord.find(params[:request_record_id])
    @service_record = @request_record
                        .create_service_record(service_type_id: params[:service_type_id],
                                               description: params[:service_description],
                                               closed_at: params[:closed_at],
                                               user_id: current_user.id
                                               )
    flash[:alert] = @service_record.errors.full_messages unless @service_record.valid?
    redirect "/request_records/#{@request_record.id}"
  end

  get "/service_records/edit/:id" do
    @service_types = ServiceType.all
    @service_record = ServiceRecord.find(params[:id])
    erb :"services/edit"
  end

  post "/service_records/edit/:id" do
    check_permission(:active)
    @service_record = ServiceRecord.find(params[:id])
    @service_record.update(service_type_id: params[:service_type_id],
                           description: params[:service_description],
                           closed_at: params[:closed_at],
                           user_id: current_user.id
                           )
    flash[:alert] = @service_record.errors.full_messages unless @service_record.valid?
    redirect "/request_records/#{@service_record.request_record.id}"
  end
end
