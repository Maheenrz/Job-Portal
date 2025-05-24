# app/models/job.rb
class Job < ApplicationRecord
  belongs_to :user
  has_many :applications, dependent: :destroy 
  
  # Validations to prevent empty job posts
  validates :title, presence: { message: "Title cannot be blank" }, 
                   length: { minimum: 3, maximum: 100, message: "Title must be between 3 and 100 characters" }
  
  validates :company_name, presence: { message: "Company name cannot be blank" },
                          length: { minimum: 2, maximum: 100, message: "Company name must be between 2 and 100 characters" }
  
  validates :location, presence: { message: "Location cannot be blank" },
                      length: { minimum: 2, maximum: 100, message: "Location must be between 2 and 100 characters" }
  
  validates :description, presence: { message: "Description cannot be blank" },
                         length: { minimum: 10, maximum: 2000, message: "Description must be between 10 and 2000 characters" }
  
  validates :employment_type, presence: { message: "Employment type must be selected" },
                             inclusion: { in: ['Full-time', 'Part-time', 'Contract', 'Internship'], 
                                        message: "Employment type must be one of: Full-time, Part-time, Contract, or Internship" }
  
  # OPTIONAL SALARY - Salary is optional but if provided, should be positive
  validates :salary, numericality: { greater_than: 0, message: "Salary must be a positive number" }, allow_blank: true
  
  # Optional: Add scope for recent jobs
  scope :recent, -> { order(created_at: :desc) }
  scope :by_employment_type, ->(type) { where(employment_type: type) }
end