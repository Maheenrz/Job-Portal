class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :only_recruiters!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_job, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_job_owner!, only: [ :edit, :update, :destroy ]

  def index
    @jobs = Job.all
  end

  def show
  end

  def new
    @job = Job.new
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      redirect_to @job, notice: "Job posted successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Job deleted."
  end

  private

  def only_recruiters!
    redirect_to root_path, alert: "Access denied." unless current_user.recruiter?
  end

  def set_job
    @job = Job.find(params[:id])
  end

  def authorize_job_owner!
    if @job.user != current_user
      redirect_to jobs_path, alert: "You are not authorized to modify this job."
    end
  end

  def job_params
    params.require(:job).permit(:title, :description, :location, :company_name, :employment_type, :salary)
  end
end
