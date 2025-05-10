class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.string :location
      t.string :company_name
      t.string :employment_type
      t.string :salary
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
