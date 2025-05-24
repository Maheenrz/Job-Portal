# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :validatable

  enum :role, { job_seeker: 1, recruiter: 2 }

  has_many :jobs, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_one_attached :resume
  has_one_attached :profile_picture

  # Validations - only for fields in your profile form
  validates :username, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" },
            length: { in: 3..20 }
  validates :first_name, :last_name, presence: true, length: { maximum: 50 }
  validates :phone_number, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :linkedin_url, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0, less_than: 100 }, allow_blank: true
  validates :bio, length: { maximum: 1000 }

  # Callbacks
  before_save :normalize_username
  after_update :update_profile_completion

  def recruiter?
    role == "recruiter"
  end

  def job_seeker?
    role == "job_seeker"
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def skills_array
    return [] if skills.blank?
    skills.split(',').map(&:strip).reject(&:empty?)
  end

  def skills_array=(array)
    self.skills = array.join(', ')
  end

  def profile_completion_percentage
    # Only count fields that exist in your profile form
    required_fields = %w[username first_name last_name]
    optional_fields = %w[phone_number location bio skills linkedin_url years_of_experience]
    
    completed_required = required_fields.count { |field| self[field].present? }
    completed_optional = optional_fields.count { |field| self[field].present? }
    
    # Add bonus for attachments
    completed_optional += 1 if resume.attached?
    completed_optional += 1 if profile_picture.attached?
    
    total_required = required_fields.length
    total_optional = optional_fields.length + 2 # +2 for attachments
    
    # Calculate percentage: Required fields are worth 60%, optional 40%
    required_percentage = (completed_required.to_f / total_required) * 60
    optional_percentage = (completed_optional.to_f / total_optional) * 40
    
    (required_percentage + optional_percentage).round
  end

  def profile_complete?
    profile_completion_percentage >= 80
  end

  private

  def normalize_username
    self.username = username.downcase if username.present?
  end

  def update_profile_completion
    # Update profile completion status
    new_completion = profile_complete?
    if respond_to?(:profile_completed) && self.profile_completed != new_completion
      update_column(:profile_completed, new_completion)
    end
  end
end