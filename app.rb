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
      unless current_log_owner?
        check_current_key
        unless current_key.send(:"#{status}?")
          flash[:info] = "Operation cancelled! Only #{status} users can perform this action"
          redirect back
        end
      end
    end

    def current_log_owner?
      current_log.owner_user == current_user
    end

    def check_current_key
      if current_key.nil?
        flash[:alert] = "Please select a log you have an access key associated"
        redirect "/users/account"
      end
    end

    def login(user)
      session[:user_id] = user.id
      load_logged_log
    end

    def load_logged_log
      session[:log_id] = current_user.logged_log&.id
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

    def current_log
      @current_log ||= Log.find_by(id: session[:log_id])
    end

    # Returns the assemblies for the current log
    def assemblies
      @assemblies ||= current_log&.assemblies
    end

    # Returns the entities for the current log
    def entities
      @entities ||= current_log&.entities
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

  get "/confirm_delete/:table/:id" do
    @table = params[:table]
    @id = params[:id]
    erb :"shared/confirm_delete"
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
    @log = current_user.personal_logs.create(name: params[:name],
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
      load_logged_log
      flash[:info] = "Log #{@load_key.log.name} is now selected"
      redirect "/"
    else
      flash[:alert] = "No log found or no access granted"
      redirect back
    end
  end

  get "/logs" do
    check_permission(:admin)
    erb :"logs/index"
  end

  post "/logs/add_key" do
    check_permission(:admin)
    if current_user.authenticate(params[:check_password])
      @user = User.find_by(email: params[:user_email])
      if @user
        @key = Key.create(log_id: current_log.id,
                       user_id: @user.id,
                       admin: params[:admin],
                       active: params[:active])
        if @key.valid?
          flash[:info] = "An access key was created for #{@user.full_name}"
        else
          flash[:alert] = @key.errors.full_messages
        end
      else
        flash[:alert] = "User not found"
      end
    else
      flash[:alert] = "Wrong password"
    end
    redirect "/logs"
  end

  get "/logs/revoke_key/:id" do
    check_permission(:admin)
    @key = Key.find_by(id: params[:id])
    if @key.log == current_log
      @key.destroy
      # Corfirm the key is destroyed
      unless Key.all.include?(@key)
        flash[:info] = "Revoked key for #{@key.user.email}"
      else
        flash[:alert] = "Key for #{@key.user.email} was not destroyed"
      end
    else
      flash[:alert] = "This key does not belong to the actual log"
    end
    redirect "/logs"
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

  get "/assemblies/edit/:id" do
    check_permission(:admin)
    @assembly = assemblies.find_by(id: params[:id])
    erb :"assemblies/edit"
  end

  post "/assemblies/edit/:id" do
    check_permission(:admin)
    @assembly = assemblies.find_by(id: params[:id])
    @assembly.update(description: params[:description],
                     manufacturer: params[:manufacturer],
                     model: params[:model])
    flash[:alert] = @assembly.errors.full_messages unless @assembly.valid?
    redirect "/assemblies/#{@assembly.id}"
  end

  post "/assemblies/delete/:id" do
    if current_log_owner?
      assembly = assemblies.find_by(id: params[:id])
      if current_user.authenticate(params[:password])
        assembly.destroy
        flash[:info] = "#{assembly.description} was deleted"
        redirect "/assemblies"
      else
        flash[:alert] = "Password is incorrect!"
        redirect "/assemblies/#{assembly.id}"
      end
    end
  end


  # Entities routes

  get "/entities" do
    erb :"entities/index"
  end

  get "/entities/new" do
    check_permission(:admin)
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

  get "/entities/edit/:id" do
    check_permission(:admin)
    @entity = entities.find_by(id: params[:id])
    erb :"entities/edit"
  end

  post "/entities/edit/:id" do
    check_permission(:admin)
    @entity = entities.find_by(id: params[:id])
    @entity.update(number: params[:number],
                   description: params[:description],
                   assembly_id: params[:assembly_id],
                   serial: params[:serial])
    flash[:alert] = @entity.errors.full_messages unless @entity.valid?
    redirect "/entities/#{@entity.id}"
  end

  post "/entities/delete/:id" do
    if current_log_owner?
      entity = entities.find_by(id: params[:id])
      if current_user.authenticate(params[:password])
        entity.destroy
        flash[:info] = "#{entity.number} was deleted"
        redirect "/entities"
      else
        flash[:alert] = "Password is incorrect!"
        redirect "/entities/#{entity.id}"
      end
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
