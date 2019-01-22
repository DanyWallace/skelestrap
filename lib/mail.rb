require 'mail'

settings = IniFile.load('main.ini')

options = {
  address: settings['email']['server'],
  port: settings['email']['port'],
  user_name: settings['email']['user'],
  password: settings['email']['password'],
  authentication: 'plain',
  enable_starttls_auto: true
}

Mail.defaults do
  delivery_method :smtp, options
end

def get_user_email(user)
  address = @@client.query("SELECT Email FROM Users WHERE Username = '#{user}'").each(as: :array)
  address = address.join(', ')
  address
end

def verification_email(user)
  code = @@client.query("Select Signature FROM Users WHERE Username = '#{user}'").each(as: :array)
  code = code.join(', ')
  link = "http://#{@@url}/user/verify/#{code}"
  template_path = File.expand_path('mail/verify.txt', __dir__)
  message = File.read(template_path)
  beam = Mail.new do
    from 'doctor@melee.fun'
    to get_user_email(user)
    subject "Hi #{user}, verify your account - #{@@site_name}"
    body message + ' ' + link
  end
  beam.deliver
end
