ActiveAdmin.register_page "Settings" do
  content do
    render partial: 'settings_form'
  end

  page_action :save, :method => :post do
    params[:settings].each do |key, value|
      Settings.find_by!(key: key).update(value: value)
    end
    redirect_to admin_settings_path, notice: 'Settings were successfully updated'
  end
end