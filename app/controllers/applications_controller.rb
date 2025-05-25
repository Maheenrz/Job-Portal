class ApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, except: [ :my_applications, :show, :retry_analysis ]
  before_action :only_job_seekers!, except: [ :my_applications, :show, :retry_analysis ]
  before_action :check_existing_application!, only: [ :new, :create ]
  before_action :set_application, only: [ :show, :retry_analysis, :destroy ]

  helper_method :job_seeker?, :recruiter?

  def my_applications
    @applications = current_user.applications.includes(:job)
  end

  def job_seeker?
    user_signed_in? && current_user.job_seeker?
  end

  def recruiter?
    user_signed_in? && current_user.recruiter?
  end

  def new
    @application = Application.new
    @existing_application = current_user.applications.find_by(job_id: @job.id)
  end

  def show
    # For viewing individual applications
  end

  # Enhanced method for resume analysis
  def analyze_resume
    begin
      resume_file = params[:resume]

      unless resume_file
        render json: { error: "No resume file provided" }, status: :bad_request
        return
      end

      # Validate file type and size
      max_size = 5.megabytes
      allowed_types = [
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "text/plain"
      ]

      if resume_file.size > max_size
        render json: { error: "File size must be less than 5MB" }, status: :bad_request
        return
      end

      unless allowed_types.include?(resume_file.content_type)
        render json: { error: "File must be PDF, DOC, DOCX, or TXT format" }, status: :bad_request
        return
      end

      # Analyze the resume
      matcher = ResumeMatcherService.new(@job, resume_file)
      analysis = matcher.detailed_analysis

      # Prepare response data
      skill_matches = analysis[:skill_matches] || { matching: [], missing: [] }

      response_data = {
        match_score: analysis[:match_score] || 0,
        matching_skills: skill_matches[:matching] || [],
        missing_skills: skill_matches[:missing] || [],
        recommendations: analysis[:recommendations] || [],
        debug_info: Rails.env.development? ? analysis[:debug_info] : nil
      }

      render json: response_data

    rescue => e
      Rails.logger.error "Resume analysis error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        error: "Failed to analyze resume. Please try again or contact support.",
        debug: Rails.env.development? ? e.message : nil
      }, status: :internal_server_error
    end
  end

  def retry_analysis
    unless @application
      render json: { success: false, error: "Application not found" }
      return
    end

    begin
      # Clear previous analysis data
      @application.update!(
        match_score: nil,
        skill_analysis: nil,
        analysis_error: nil
      )

      # Trigger fresh analysis
      analyze_resume_sync(@application)

      render json: {
        success: true,
        message: "Analysis completed",
        match_score: @application.match_score
      }
    rescue => e
      Rails.logger.error "Retry analysis failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      @application.update(analysis_error: e.message)

      render json: {
        success: false,
        error: "Analysis failed: #{e.message}"
      }
    end
  end

  def create
    @application = @job.applications.build(application_params)
    @application.user = current_user

    if @application.save
      # Trigger resume analysis after successful save
      analyze_resume_async(@application)

      # Send notification email to recruiter (optional)
      begin
        ApplicationMailer.new_application_notification(@application).deliver_later if defined?(ApplicationMailer)
      rescue => e
        Rails.logger.warn "Failed to send application notification: #{e.message}"
      end

      redirect_to @job, notice: "Application submitted successfully! Resume analysis in progress."
    else
      @existing_application = current_user.applications.find_by(job: @job)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @application.destroy
    redirect_to my_applications_path, notice: "Application deleted successfully!"
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to jobs_path, alert: "Job not found."
  end

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.require(:application).permit(:cover_letter, :resume)
  end

  def only_job_seekers!
    unless current_user.job_seeker?
      redirect_to root_path, alert: "Only job seekers can apply."
    end
  end

  def check_existing_application!
    existing_application = current_user.applications.find_by(job_id: @job.id)
    if existing_application && action_name != "new"
      redirect_to job_path(@job), alert: "You have already applied to this job."
    end
  end

  def analyze_resume_async(application)
    # Use background job if available, otherwise analyze synchronously
    if defined?(AnalyzeResumeJob)
      AnalyzeResumeJob.perform_later(application.id)
    else
      analyze_resume_sync(application)
    end
  end

  def analyze_resume_sync(application)
    return unless application.resume.attached?

    begin
      Rails.logger.info "Starting resume analysis for application #{application.id}"

      # Initialize the matcher service
      matcher = ResumeMatcherService.new(application.job, application.resume)

      # Get match score and skill analysis
      score = matcher.match_score
      skills = matcher.skill_matches

      Rails.logger.info "Analysis complete - Score: #{score}, Skills: #{skills.inspect}"

      # Update the application with results
      application.update!(
        match_score: score,
        skill_analysis: skills.to_json,
        analysis_error: nil
      )

      Rails.logger.info "Successfully updated application #{application.id} with analysis results"

    rescue => e
      error_message = "Resume analysis failed: #{e.message}"
      Rails.logger.error "#{error_message} for application #{application.id}"
      Rails.logger.error e.backtrace.join("\n")

      # Store the error but don't fail the application
      application.update(
        match_score: 0,
        skill_analysis: nil,
        analysis_error: error_message
      )
    end
  end
end
