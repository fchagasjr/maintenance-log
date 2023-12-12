module SessionHelpers
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
                                      .where(entity: { assembly_id: assemblies&.ids })
  end
end
