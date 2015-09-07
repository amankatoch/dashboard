class APNConnection
  def initialize
    setup
  end

  def setup
    @certificate = File.read("#{Rails.root}/config/apn.pem")
    @uri =
      if Rails.env.production? || Rails.env.staging?
        Houston::APPLE_PRODUCTION_GATEWAY_URI
      else
        Houston::APPLE_DEVELOPMENT_GATEWAY_URI
      end

    @connection = Houston::Connection.new(@uri, @certificate, nil)
    @connection.open
  end

  def write(data)
    fail 'Connection is closed' unless @connection.open?
    @connection.write(data)
  rescue Exception => e
    attempts ||= 0
    attempts += 1

    if attempts < 5
      setup
      retry
    else
      raise e
    end
  end
end
