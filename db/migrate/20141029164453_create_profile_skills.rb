class CreateProfileSkills < ActiveRecord::Migration
  def change
    create_table :profile_skills do |t|
      t.references :profile, index: true
      t.references :skill, index: true

      t.timestamps
    end
  end
end
