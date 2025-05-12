class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  

  enum :role, { job_seeker: 1, recruiter: 2 }

  has_many :jobs, dependent: :destroy
  has_many :applications, dependent: :destroy

  def recruiter?
    role == "recruiter"
  end

  def job_seeker?
    role == "job_seeker"
  end
end
