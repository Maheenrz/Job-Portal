class HomeController < ApplicationController
  def index
    @recent_jobs = Job.order(created_at: :desc).limit(6)
  end

  def welcome
    # Only accessible to logged-in users
    redirect_to root_path unless user_signed_in?
  end
end
