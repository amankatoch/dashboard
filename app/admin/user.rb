ActiveAdmin.register User do

  permit_params :email, :password, :password_confirmation,
                { profile_attributes: [:id, :name, :age, :gender, :location, :level, :about] }


  index do
    column :email
    column 'Name', :profile
    column 'Registered At', :created_at
    column 'Registered At', :created_at
    actions
  end

  form do |f|
    f.inputs "Login Credentials" do
      f.input :email
      f.input :password, required: false
      f.input :password_confirmation, required: false
    end

    f.inputs 'Profile', for: [:profile, (f.object.profile || f.object.build_profile)] do |p|
      p.input :name
      p.input :age
      p.input :level, as: :select, collection: 1..5
      p.input :gender, as: :select, collection: [['Male', 'm'], ['Female', 'f']]
      p.input :location
      p.input :about
    end
    f.actions
  end

  show do |ad|
    attributes_table do
      row :name
      row :email
      row :level do
        user.profile.level
      end
      row :age do
        user.profile.age
      end
      row :gender do
        user.profile.gender
      end
      row :location do
        user.profile.location
      end
      row :about do
        user.profile.about
      end
    end
    active_admin_comments
  end

end
