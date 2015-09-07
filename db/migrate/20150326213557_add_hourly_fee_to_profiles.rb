class AddHourlyFeeToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :hourly_rate, :float
  end
end
