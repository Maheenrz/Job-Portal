class AddAnalysisFieldsToApplications < ActiveRecord::Migration[7.0]
  def change
    # Add columns only if they don't exist
    add_column :applications, :match_score, :integer unless column_exists?(:applications, :match_score)
    add_column :applications, :skill_analysis, :text unless column_exists?(:applications, :skill_analysis)
    add_column :applications, :analysis_error, :text unless column_exists?(:applications, :analysis_error)

    # Add index for better performance when filtering by match_score
    add_index :applications, :match_score unless index_exists?(:applications, :match_score)
  end
end
