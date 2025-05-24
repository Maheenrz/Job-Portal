# app/controllers/jobs_controller.rb
class JobsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :only_recruiters!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  before_action :authorize_job_owner!, only: [:edit, :update, :destroy]

  def index
    @jobs = Job.all

    # Filter by user's own jobs if requested (for recruiters)
    if params[:my_jobs].present? && current_user&.recruiter?
      @jobs = @jobs.where(user_id: current_user.id)
    end

    # Apply search filters
    if params[:keyword].present?
      @jobs = @jobs.where("title ILIKE :q OR description ILIKE :q", q: "%#{params[:keyword]}%")
    end

    if params[:location].present?
      @jobs = @jobs.where("location ILIKE ?", "%#{params[:location]}%")
    end

    if params[:type].present? && params[:type] != "All Types"
      @jobs = @jobs.where(employment_type: params[:type])
    end

    @jobs = @jobs.order(created_at: :desc).page(params[:page]) # if using pagination
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
      # This will show validation errors on the form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Job deleted."
  end

  private

  def only_recruiters!
    redirect_to root_path, alert: "Access denied. Only recruiters can perform this action." unless current_user.recruiter?
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