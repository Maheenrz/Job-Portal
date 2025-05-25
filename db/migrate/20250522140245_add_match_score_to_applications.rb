
class AddMatchScoreToApplications < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:applications, :match_score)
      add_column :applications, :match_score, :decimal, precision: 5, scale: 2, default: 0.0
    end
  end
end
