class ConfirmationsController < Devise::ConfirmationsController
  def confirmed
  end


  def after_confirmation_path_for(resource_name, resource)
    confirmed_user_url
  end
end