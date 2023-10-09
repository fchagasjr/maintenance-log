require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require_relative 'lib/user'
require_relative 'lib/log'
require_relative 'lib/key'
require_relative 'lib/assembly'
require_relative 'lib/entity'
require_relative 'lib/request_record'
require_relative 'lib/request_type'
require_relative 'lib/service_record'
require_relative 'lib/service_type'

class App < Sinatra::Base
  helpers do

    # Check permissions current user has for the current log
    def check_permission(status)
      unless current_key.send(:"#{status}?")
        flash[:info] = "Operation cancelled! Only #{status} users can perform this action"
        redirect back
      end
    end

    def login(user)
      session[:user_id] = user.id
      load_user_log
    end

    def load_user_log
      session[:log_id] = current_user.log_id
    end

    def logout
      session[:user_id] = nil
      session[:log_id] = nil
    end

    def logged_in?
      !current_user.nil?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    # Returns the user access keys for the current log
    def current_key
      @current_key ||= Key.find_by(user_id: session[:user_id], log_id: session[:log_id])
    end

    # Returns the assemblies for the current log
    def assemblies
      @assemblies ||= Assembly.where(log_id: current_key&.log_id)
    end

    # Returns the entities for the current log
    def entities
      @entities ||= Entity.joins(:assembly).where(assembly: { log_id: current_key&.log_id })
    end

    # Returns the request records for the current log
    def request_records
      @request_records ||= RequestRecord.joins(:entity)
                                        .where(entity: { assembly_id: assemblies.ids })
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
    unless current_user.authenticate(params[:check_password])
      flash[:alert] = "Wrong password"
      redirect "/users/edit"
    end
    current_user.update(first_name: params[:first_name],
                        last_name: params[:last_name],
                        email: params[:email])
    if current_user.valid?
      flash[:info] = "User account updated"
      redirect "/users/account"
    else
      flash[:alert] = current_user.errors.full_messages
      current_user.reload
      redirect "/users/edit"
    end
  end

  get "/users/password" do
    erb :"users/password"
  end

  post "/users/password" do
    unless current_user.authenticate(params[:password])
      flash[:alert] = "Wrong actual password"
      redirect "/users/password"
    end
    current_user.update(password: params[:new_password],
                        password_confirmation: params[:new_password_confirmation])
    if current_user.valid?
      flash[:info] = "New password updated"
      redirect "/users/account"
    else
      flash[:alert] = current_user.errors.full_messages
      redirect "/users/password"
    end
  end

  # Log routes

  post "/logs" do
    @log = Log.new(name: params[:name],
                   description: params[:description])
    if @log.valid?
      @log.save
      @log.keys.create(user_id: current_user.id,
                       admin: true,
                       active: true)
      flash[:info] = "Log #{@log.name} was successfully created"
    else
      flash[:alert] = @log.errors.full_messages
    end
    redirect "/users/account"
  end

  get "/logs/access/:id" do
    # Check if user has permission to access the log
    @load_key = Key.find_by(user_id: current_user.id, log_id: params[:id])
    if @load_key
      current_user.update(log_id: @load_key.log_id)
      load_user_log
      flash[:info] = "Log #{@load_key.log.name} is now selected"
      redirect "/"
    else
      flash[:alert] = "No log found or no access granted"
      redirect back
    end
  end

  # Assembly routes

  get "/assemblies" do
    erb :"assemblies/index"
  end

  get "/assemblies/new" do
    check_permission(:admin)
    erb :"assemblies/new"
  end

  get "/assemblies/:id" do
    @assembly = assemblies.find(params[:id])
    erb :"assemblies/show"
  end

  post "/assemblies" do
    check_permission(:admin)
    @assembly = Assembly.new(description: params[:description],
                             manufacturer: params[:manufacturer],
                             model: params[:model],
                             log_id: session[:log_id])
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
    erb :"entities/index"
  end

  get "/entities/new" do
    erb :"entities/new"
  end

  get "/entities/:id" do
    @entity = entities.find(params["id"].to_s)
    erb :"entities/show"
  end

  post "/entities" do
    check_permission(:admin)
    @entity = Entity.new(number: params[:number],
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
    erb :"requests/new"
  end

  get "/request_records/:id" do
    @request_record = request_records.find(params[:id])
    erb :"requests/show"
  end

  post "/request_records" do
    check_permission(:active)
    entity = entities.find_by(number: params[:entity_number]) # Check entities within current log
    @request_record = RequestRecord.new(entity_id: entity&.id, #Safe operator in case no entity is found
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
    @request_types = RequestType.all
    @request_record = request_records.find(params[:id])
    erb :"requests/edit"
  end

  post "/request_records/edit/:id" do
    check_permission(:active)
    @request_record = request_records.find(params[:id])
    entity = entities.find_by(number: params[:entity_number].upcase) # Check entities within current log
    @request_record.update(entity_id: entity&.id, #Safe operator in case no entity is found
                           request_type_id: params[:request_type_id],
                           description: params[:request_description],
                           user_id: current_user.id
                           )
    flash[:alert] = @request_record.errors.full_messages  unless @request_record.valid?
    redirect "/request_records/#{@request_record.id}"
  end

  # Service routes

  get "/service_records/new" do
    @request_record = request_records.find(params[:request_record_id])
    @service_types = ServiceType.all
    erb :"services/new"
  end

  post "/service_records" do
    check_permission(:active)
    @request_record = request_records.find(params[:request_record_id])
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
