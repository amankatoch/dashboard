class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :age, :gender, :level, :location, :about, :availability,
             :photo_public_id, :hourly_rate

  has_many :skills

  def availability
    object.availabilities.map do |a|
      { day: a.day, time: a.time }
    end.sort do |a, b|
      ProfileAvailability::DAYS_OPTIONS.index(a[:day]) <=> ProfileAvailability::DAYS_OPTIONS.index(b[:day])
    end
  end
end
