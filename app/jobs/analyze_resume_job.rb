# app/jobs/analyze_resume_job.rb
class AnalyzeResumeJob < ApplicationJob
  queue_as :default

  # Retry up to 3 times with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(application_id)
    application = Application.find_by(id: application_id)

    unless application
      Rails.logger.error "Application #{application_id} not found for resume analysis"
      return
    end

    unless application.resume.attached?
      Rails.logger.error "No resume attached for application #{application_id}"
      application.update(analysis_error: "No resume file found")
      return
    end

    Rails.logger.info "Starting background resume analysis for application #{application_id}"

    begin
      # Initialize the matcher service
      matcher = ResumeMatcherService.new(application.job, application.resume)

      # Get match score and skill analysis
      score = matcher.match_score
      skills = matcher.skill_matches

      Rails.logger.info "Background analysis complete - Application: #{application_id}, Score: #{score}"

      # Update the application with results
      application.update!(
        match_score: score,
        skill_analysis: skills.to_json,
        analysis_error: nil
      )

      Rails.logger.info "Successfully updated application #{application_id} with background analysis results"

      # Optional: Send notification to job poster about new application
      # NotificationMailer.new_application(application).deliver_now

    rescue => e
      error_message = "Resume analysis failed: #{e.message}"
      Rails.logger.error "#{error_message} for application #{application_id}"
      Rails.logger.error e.backtrace.join("\n")

      # Store the error
      application.update(
        match_score: 0,
        skill_analysis: nil,
        analysis_error: error_message
      )

      # Re-raise to trigger retry mechanism
      raise e
    end
  end
end
