class ApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job
  before_action :only_job_seekers!

  def new
    @application = Application.new
  end

  def create
    @application = @job.applications.build(application_params)
    @application.user = current_user

    if @application.save
      redirect_to @job, notice: "Application submitted!"
    else
      render :new
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def application_params
    params.require(:application).permit(:cover_letter)
  end

  def only_job_seekers!
    redirect_to root_path, alert: "Only job seekers can apply." unless current_user.job_seeker?
  end
end
