RSpec.configure do |config|
  # config.before(:suite) do
  #   Apipie.record('examples')
  # end

  config.filter_run :show_in_doc => true if ENV['APIPIE_RECORD']
end
