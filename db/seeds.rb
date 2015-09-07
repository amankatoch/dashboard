# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email: 'test@practicegigs.com',
  password: 'PracticeTest123!', password_confirmation: 'PracticeTest123!')


['Forehand', 'Backhand', 'Training', 'Serve'].each do |skill|
  Skill.find_or_create_by(name: skill)
end