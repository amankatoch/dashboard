class CreateProfileAvailabilities < ActiveRecord::Migration
  def change
    create_table :profile_availabilities do |t|
      t.references :profile, index: true
      t.string :day
      t.string :time

      t.timestamps
    end
  end
end
