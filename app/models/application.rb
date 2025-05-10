class Application < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :cover_letter, presence: true
end
