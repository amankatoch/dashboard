class PasswordsController < Devise::PasswordsController
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end

  def changed
  end

  def after_resetting_password_path_for(resource)
    password_changed_path
  end
end