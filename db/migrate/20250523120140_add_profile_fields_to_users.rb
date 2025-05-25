# db/migrate/add_profile_fields_to_users.rb
class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
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
    add_column :users, :skills, :text # Store as comma-separated or JSON
    add_column :users, :profile_completed, :boolean, default: false

    add_index :users, :username, unique: true
  end
end
