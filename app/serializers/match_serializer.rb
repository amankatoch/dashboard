class MatchSerializer < ActiveModel::Serializer
  attributes :session_request_id, :player, :message, :initiated_by_me, :days, :status,
             :accepted_rejected_at, :locations, :invited_user_comment, :created_at, :updated_at

  def session_request_id
    object.id
  end

  def initiated_by_me
    scope[:current_user].id == object.user_id
  end

  def player
    if scope[:current_user].id == object.invited_user_id
      { id: object.user_id, name: object.user.name,
        photo_public_id: object.user.profile.photo_public_id }
    else
      { id: object.invited_user_id, name: object.invited_user.name,
        photo_public_id: object.invited_user.profile.photo_public_id }
    end
  end

  def locations
    if object.confirmed?
      [object.location]
    elsif object.accepted_locations && object.accepted_locations.any?
      object.accepted_locations
    else
      object.locations
    end
  end

  def days
    if object.confirmed?
      object.days.confirmed.map do |d|
        { date: d.date, time_start: (d.accepted_time_start || d.time_start).to_s(:ampm), time_end: (d.accepted_time_end || d.time_end).to_s(:ampm) }
      end
    elsif object.accepted?
      object.days.accepted.map do |d|
        { date: d.date, time_start: (d.accepted_time_start || d.time_start).to_s(:ampm), time_end: (d.accepted_time_end || d.time_end).to_s(:ampm) }
      end
    else
      object.days.map do |d|
        { date: d.date, time_start: d.time_start.to_s(:ampm), time_end: d.time_end.to_s(:ampm) }
      end
    end
  end
end
