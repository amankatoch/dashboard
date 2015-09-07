if Rails.env.production? || Rails.env.staging?
  APN = Houston::Client.production
else
  APN = Houston::Client.development
end
APN.certificate = File.read(Rails.root.join('config', 'apn.pem'))
