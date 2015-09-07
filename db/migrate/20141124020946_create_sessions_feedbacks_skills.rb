class CreateSessionsFeedbacksSkills < ActiveRecord::Migration
  def change
    create_table :sessions_feedbacks_skills, id: false do |t|
      t.references :skill, index: true
      t.references :sessions_feedback, index: true
    end
  end
end
