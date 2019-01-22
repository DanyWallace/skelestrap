# Your sso secret key should be in your main.ini file.

def hmac_hex(payload) # gets signature
  settings = IniFile.load('main.ini')
  key = settings['sso']['secret']
  return OpenSSL::HMAC.hexdigest("sha256", key, payload)
end

def current_user_sso (nonce, callback_url)
  authorized?
  id = user_info(@user_name, 'id')
  real_name = user_info(@user_name, 'Name')
  pic = user_info(@user_name, 'Pic')
  email = user_info(@user_name, 'email')

  nonce = nonce.join(", ")
  callback_url = callback_url.join(", ")
  
  # if email is not verified require_activation = true

  payload = "nonce=#{nonce}&email=#{email}&external_id=#{id}&username=#{@user_name}&name=#{real_name}&avatar_url=#{@url}/avys/#{pic}"
  #encoded
  encoded_payload = Base64.encode64(payload)
  signature = hmac_hex(encoded_payload)   #sig of payload
  encoded_payload = URI.escape(encoded_payload) 

  return "#{callback_url}?sso=#{encoded_payload}&sig=#{signature}"
end

get '/session/sso_provider/' do
  authorized?
  #parsed = parsesso(params[:sso], params[:sig], key)
  if hmac_hex(params[:sso]) == params[:sig]
  	parsed_load = CGI::parse(Base64.decode64(params[:sso]))

    sso_url = current_user_sso(parsed_load['nonce'], parsed_load['return_sso_url'])

    redirect to(sso_url)
  else
  "Params[:sso]#{params[:sso]} \n" + "Params[:sig]#{params[:sig]}\n\n"
  end
end