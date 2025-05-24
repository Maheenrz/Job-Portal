class AddAnalysisErrorToApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :applications, :analysis_error, :text
  end
end
