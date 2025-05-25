# app/models/application.rb
class Application < ApplicationRecord
  belongs_to :user
  belongs_to :job

  has_one_attached :resume

  validates :user_id, uniqueness: { scope: :job_id, message: "You have already applied to this job" }
  validates :resume, presence: { message: "Please upload your resume" }

  # Validate file size and type
  validate :resume_validation

  # Scopes for filtering by match score
  scope :high_match, -> { where("match_score >= ?", 70) }
  scope :medium_match, -> { where("match_score >= ? AND match_score < ?", 40, 70) }
  scope :low_match, -> { where("match_score < ? OR match_score IS NULL", 40) }
  scope :with_analysis, -> { where.not(match_score: nil) }
  scope :without_analysis, -> { where(match_score: nil) }

  # Method to get parsed skill analysis
  def parsed_skill_analysis
    return {} if skill_analysis.blank?

    begin
      JSON.parse(skill_analysis)
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse skill_analysis for application #{id}: #{e.message}"
      {}
    end
  end

  # Method to check if analysis is complete
  def analysis_complete?
    match_score.present?
  end

  # Method to check if analysis failed
  def analysis_failed?
    analysis_error.present?
  end

  # Method to get match score category
  def match_category
    return "unknown" unless match_score.present?

    case match_score
    when 70..100
      "high"
    when 40...70
      "medium"
    when 0...40
      "low"
    else
      "unknown"
    end
  end

  # Method to get match score color class
  def match_score_class
    case match_category
    when "high"
      "success"
    when "medium"
      "warning"
    when "low"
      "danger"
    else
      "secondary"
    end
  end

  # Method to trigger resume analysis
  def analyze_resume!
    return false unless resume.attached?

    begin
      Rails.logger.info "Triggering resume analysis for application #{id}"

      matcher = ResumeMatcherService.new(job, resume)
      score = matcher.match_score
      skills = matcher.skill_matches

      update!(
        match_score: score,
        skill_analysis: skills.to_json,
        analysis_error: nil
      )

      Rails.logger.info "Resume analysis completed for application #{id} - Score: #{score}"
      true

    rescue => e
      error_message = "Resume analysis failed: #{e.message}"
      Rails.logger.error "#{error_message} for application #{id}"

      update(
        match_score: 0,
        skill_analysis: nil,
        analysis_error: error_message
      )

      false
    end
  end

  private

  def resume_validation
    return unless resume.attached?

    # Check file size (5MB limit)
    if resume.blob.byte_size > 5.megabytes
      errors.add(:resume, "File size must be less than 5MB")
    end

    # Check file type
    allowed_types = [
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "text/plain"
    ]

    unless allowed_types.include?(resume.content_type)
      errors.add(:resume, "File must be PDF, DOC, DOCX, or TXT format")
    end
  end
end
