class ProfileAvailability < ActiveRecord::Base
  belongs_to :profile

  DAYS_OPTIONS = %w(any mon tue wed thu fri wed sat sun)
  TIME_OPTIONS = %w(morning afternoon night)
end
