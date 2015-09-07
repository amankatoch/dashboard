ActiveAdmin.register ApiToken do

  permit_params :token, :name

  form do |f|
    f.inputs "Token Attributes" do
      f.input :name
      f.input :token if f.object.persisted?
    end

    f.actions
  end


end
