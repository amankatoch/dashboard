ActiveAdmin.register SessionRequest, as: 'Match' do

  actions :index, :show

  index do
    column 'Requester' do |match|
      match.user.name
    end
    column 'Invited' do |match|
      match.invited_user.name
    end
    column :status
    column 'Created At', :created_at
    actions
  end

  show do |ad|
    attributes_table do
      row 'Requester' do
        "#{match.user.name} (#{match.user.email})"
      end
      row 'Invited' do
        "#{match.invited_user.name} (#{match.invited_user.email})"
      end
      row :status
      row :locations do
        if match.status == 'accepted'
          match.accepted_locations.join ', ' if match.accepted_locations
        else
          match.locations.join ', ' if match.locations
        end
      end

    end

    panel "TimeSlots" do
      table_for match.days do
        column :date
        column :time do |day|
          "#{day.time_start.to_s(:ampm)} - #{day.time_end.to_s(:ampm)}"
        end
        column :accepted
        column :confirmed
        # ...
      end
    end

    active_admin_comments
  end

  filter :user_profile_name, label: 'Requester User', as: :string
  filter :invited_user_profile_name, label: 'Invited User', as: :string
  filter :status, as: :check_boxes, collection: SessionRequest.statuses
  filter :created_at

end
