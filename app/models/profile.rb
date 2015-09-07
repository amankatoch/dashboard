class Profile < ActiveRecord::Base
  acts_as_geolocated

  belongs_to :user
  has_many :profile_skills
  has_many :skills, through: :profile_skills
  has_many :availabilities, class: ProfileAvailability, autosave: true

  validates :name, presence: true, length: { minimum: 2 }
  validates :age, presence: true, inclusion: { in: 1..100 }
  validates :gender, presence: true, inclusion: { in: %w(f m) }
  validates :level, presence: true, inclusion: { in: 1..5 }
  validates :location, presence: true, length: { minimum: 2 }

  def availability=(availability)
    return unless availability.present?
    availability.each do |day|
      existing_availability = availabilities.find { |a| a.day == day[:day] }
      if existing_availability.present?
        existing_availability.time = day[:time]
      else
        availabilities.build(day: day[:day], time: day[:time])
      end
    end
    days = availability.map { |v| v[:day] }
    availabilities.each { |a| a.mark_for_destruction unless days.include?(a.day) }
  end
end
