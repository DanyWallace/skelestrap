require 'sinatra'
require 'sinatra/multi_route' #sinatra contrib
require "sinatra/reloader" #if development? #same gem ^
require 'mysql2' #orignal mysql gem is not maintained anymore
require 'digest/whirlpool' #hash algorithm for user passwords
require 'bundler/setup'
require 'openssl'
require 'jwt' #auth tokens
require 'inifile' #loads ini files
require 'net/http'
require 'base64'
require 'cgi'

#Load settings
settingini = IniFile.load('main.ini')

#Before modukes, these are the basics
load 'lib/utils.rb'
load 'lib/users.rb'
load 'lib/auth.rb'
load 'lib/mail.rb'
load 'lib/api.rb'

# Load 'modules', nothing else will be loaded automatically
Dir["lib/*.mod.rb"].each { |file| load file }

get '/' do
  if authorized?
    erb :front
  else
    redirect to('/blog/')
  end
end


get '/login' do
  @title = 'Login'
  authorize!
  erb :login
end

post '/login' do
  if trylogin(params[:username].to_s, params[:password].to_s ) == false
    @error = true
    erb :login
  else
    exp = Time.now.to_i + 14400
    user_meta = @@client.query("Select * FROM Users WHERE Username = '#{@user}'").each(:as => :hash) #get BASIC user details
    payload = { :user_id => "#{user_meta[0]['id']}", :user_name => params[:username].to_s, :rank => "#{user_meta[0]['Rank']}" , :exp => exp }
    #Select one, and make sure to chage auth.rb as well.
    @token = JWT.encode payload, settings.hkey, 'HS256' 
    #@token = JWT.encode payload, settings.signing_key, 'RS256'

    session["access_token"] = @token
    redirect to("/")
  end

end

get '/logout' do
  session["access_token"] = nil
  redirect to("/")
end

get '/register' do
  @title = 'Register'
  erb :register
end

post '/register' do
  badinfo = isinfocorrect(params[:username], params[:useremail])
  passsafe = passissafe(params[:userpassword], params[:userpasswordconfirm])
  user_name = params[:username].to_s
  password = params[:userpassword].to_s
  real_name = params[:real_name].to_s
  email = params[:useremail].to_s
  bio = params[:bio]
  shady_level = settingini['security']['shadyness'] # max score from nofraud
  if ip_info(request.ip).to_f >= shady_level.to_f
    @error = true
    @message = 'bit shady?'
    erb :register
  elsif badinfo == true
    @error = true
    @message = 'Username or email already taken... or your info could be bad... :S'
    erb :register
  elsif passsafe == false
    @error = true
    @message << '.... passwords dont match :('
    erb :register
  else
    createuser(user_name, password, email, real_name, bio)
    @message = "Created user #{params[:username]}. Good luck!"
    verification_email(user_name)
    erb :register
  end
end

get '/killme' do # shuts the process, requires you to be of a high rank tho
  protected!
  authorize!
  if user_info(@user_name, 'Rank').to_i >= 9
    Process.kill 9, Process.pid
  else
    "Nope #{user_info(@user_name, 'Rank')}"
  end
end