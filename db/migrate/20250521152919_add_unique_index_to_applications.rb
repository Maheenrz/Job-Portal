class AddUniqueIndexToApplications < ActiveRecord::Migration[7.0]
  def change
    # Add unique index for username if it doesn't exist
    unless index_exists?(:users, :username)
      add_index :users, :username, unique: true
    end

    # Also ensure username column exists (in case migration wasn't run)
    unless column_exists?(:users, :username)
      add_column :users, :username, :string
      add_column :users, :first_name, :string
      add_column :users, :last_name, :string
      add_column :users, :phone_number, :string
      add_column :users, :location, :string
      add_column :users, :bio, :text
      add_column :users, :linkedin_url, :string
      add_column :users, :website_url, :string
      add_column :users, :years_of_experience, :integer
      add_column :users, :current_job_title, :string
      add_column :users, :skills, :text
      add_column :users, :profile_completed, :boolean, default: false
    end
  end
end
