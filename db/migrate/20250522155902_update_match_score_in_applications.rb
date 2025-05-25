# db/migrate/xxx_update_match_score_in_applications.rb
class UpdateMatchScoreInApplications < ActiveRecord::Migration[7.0]
  def change
    # Remove the old column if it exists with wrong type
    if column_exists?(:applications, :match_score) &&
       columns(:applications).find { |c| c.name == 'match_score' }.type == :decimal
      remove_column :applications, :match_score
    end

    # Add the match_score column with proper type if it doesn't exist
    unless column_exists?(:applications, :match_score)
      add_column :applications, :match_score, :integer, default: 0
    end

    # Add an index for performance when filtering
    add_index :applications, :match_score, if_not_exists: true
  end
end
