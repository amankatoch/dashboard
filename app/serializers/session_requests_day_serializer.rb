class SessionRequestsDaySerializer < ActiveModel::Serializer
  attributes :id, :date, :accepted, :confirmed, :time_start, :time_end,
             :accepted_time_start, :accepted_time_end

  def date
    object.date.to_s(:slashes)
  end

  def time_start
    object.time_start.to_s(:ampm)
  end

  def time_end
    object.time_end.to_s(:ampm)
  end

  def accepted_time_start
    object.accepted_time_start.to_s(:ampm) if object.accepted && object.accepted_time_start
  end

  def accepted_time_end
    object.accepted_time_end.to_s(:ampm) if object.accepted && object.accepted_time_end
  end
end
