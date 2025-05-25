class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  protected

  # Allow the role, username, and name parameters for sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role, :username, :first_name, :last_name ])
  end

  # Allow additional parameters for account update
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :role,
      :username,
      :first_name,
      :last_name,
      :phone_number,
      :location,
      :bio,
      :skills,
      :linkedin_url,
      :years_of_experience,
      :resume
    ])
  end

  # Redirect after sign up to welcome page
  def after_sign_up_path_for(resource)
    welcome_path
  end
end
