# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit
    # Show profile edit form
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      # Pass validation errors to the view
      flash.now[:alert] = "Please fix the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    # For viewing other user profiles (optional)
    @user = User.find_by(username: params[:username]) || User.find(params[:id])
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :username, :first_name, :last_name, :phone_number,
      :location, :bio, :linkedin_url, :years_of_experience,
      :skills, :resume, :profile_picture
    )
  end
end
