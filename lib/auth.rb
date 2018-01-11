signing_key_path = File.expand_path("../app.rsa", __FILE__)
verify_key_path = File.expand_path("../app.rsa.pub", __FILE__)

signing_key = ""
verify_key = ""

File.open(signing_key_path) do |file|
  signing_key = OpenSSL::PKey.read(file)
end

File.open(verify_key_path) do |file|
  verify_key = OpenSSL::PKey.read(file)
end

set :signing_key, signing_key
set :verify_key, verify_key

# enable sessions which will be our default for storing the token
enable :sessions

#this is to encrypt the session, but not really necessary just for token because we aren't putting any sensitive info in there
set :session_secret, 'holy batman'

helpers do

  # protected just does a redirect if we don't have a valid token
  def protected!
    return if authorized?
    redirect to('/login')
  end

  # helper to extract the token from the session, header or request param
  # if we are building an api, we would obviously want to handle header or request param
  def extract_token
    # check for the access_token header
    token = request.env["access_token"]
    
    if token
      return token
    end

    # or the form parameter _access_token
    token = request["access_token"]

    if token
      return token
    end

    # or check the session for the access_token
    token = session["access_token"]

    if token
      return token
    end

    return nil
  end

  # check the token to make sure it is valid with our public key
  def authorized?
    @token = extract_token
    #someoneauthed = `echo "\n//tried to login with this token// #{@token} //end//" >> log.txt`

    begin
      payload, header = JWT.decode @token, settings.verify_key, true, { :algorithm => 'RS256' }
      @exp = payload['exp']
      #authworked = `echo " // payload: #{payload} expppp: #{payload['exp']} // end//" >> log.txt`
      #check to see if the exp is set (we don't accept forever tokens)
      if @exp.nil?
        puts "Access token doesn't have exp set"
        return false
      end

      @exp = Time.at(@exp.to_i)

      # make sure the token hasn't expired
      if Time.now > @exp
        puts "Access token expired"
        return false
      end

      @user_id = payload['user_id']
      @user_name = payload['user_name']
    rescue JWT::DecodeError => e
      return false
    end
  end

  def authorize!
    @token = extract_token
    #someoneauthed = `echo "\n//tried to login with this token// #{@token} //end//" >> log.txt`

    begin
      payload, header = JWT.decode @token, settings.verify_key, true, { :algorithm => 'RS256' }
      @exp = payload['exp']
      someoneauthed = `echo " // payload: #{payload} expppp: #{payload['exp']} // end//" >> log.txt`
      # check to see if the exp is set (we don't accept forever tokens)
      if @exp.nil?
        puts "Access token doesn't have exp set"
        return false
      end

      @exp = Time.at(@exp.to_i)

      # make sure the token hasn't expired
      if Time.now > @exp
        puts "Access token expired"
        return false
      end

      @user_id = payload['user_id']
      @user_name = payload['user_name']
    rescue JWT::DecodeError => e
      return false
    end
  end
end