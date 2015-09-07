require 'apn_connection'

class ApnJob
  @queue = :apn

  APN_POOL = ConnectionPool.new(size: 2, timeout: 300) do
    APNConnection.new
  end

  def self.perform(token, alert, opts = {})
    APN_POOL.with do |connection|
      notification = Houston::Notification.new(device: token)
      notification.alert = alert
      notification.sound = 'default'
      notification.badge = opts['badge'] if opts.key?('badge')
      connection.write(notification.message)
    end
  end
end
