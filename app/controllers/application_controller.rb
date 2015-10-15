class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_authenticity_token
  add_flash_types :error, :success

  layout :layout_by_resource
  
  def after_sign_in_path_for(resource)
    if resource.class.to_s == 'Admin'
      admin_users_path
    else
      home_profile_path
    end
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  def invalid_authenticity_token
    render file: 'public/422.html'
  end

  protected

  def layout_by_resource
    if devise_controller?
      if resource_name == :admin
        "admin"
      else
        "devise"
      end
    else
      "application"
    end
  end
end
