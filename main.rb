require 'rubygems'
require 'sinatra'
require 'sinatra/multi_route' #sinatra contrib
require "sinatra/reloader" #if development? #same gem ^
require 'mysql2'
require 'digest'
require 'digest/whirlpool' #hash algorithm for user passwords
require 'bundler/setup' 
require 'openssl'
require 'jwt' #auth tokens
require 'inifile' #loads ini files

load 'lib/users.rb'
load 'lib/auth.rb'
Dir["lib/*.mod.rb"].each { |module| load module }

settingini = IniFile.load('main.ini')

@@client = Mysql2::Client.new(
	:host => "#{settingini['db']['host']}",
	:username => "#{settingini['db']['username']}",
	:database => "#{settingini['db']['database']}",
	:password => "#{settingini['db']['password']}" )

get '/' do
	protected!
	@title = "test"
	erb :front
end

get '/login' do
	authorize!
	erb :login
end

post '/login' do
	if trylogin("#{params[:username]}", "#{params[:password]}") == false
		@error = true
		erb :login
	else 
		id = trylogin(params[:username], params[:password])
		exp = Time.now.to_i + 3600
		payload = { :user_id => "#{id}", :user_name => "#{params[:username]}", :exp => exp }
		@token = JWT.encode payload, settings.signing_key, 'RS256'

		#checklog = `echo "//login// #{@token} //end//" >> log.txt`
		session["access_token"] = @token
		redirect to("/")
	end
end

get '/logout' do
  session["access_token"] = nil
  redirect to("/")
end

get '/register' do
	erb :register
end

post '/register' do
	badinfo = isinfocorrect(params[:username], params[:useremail])
	passsafe = passissafe(params[:userpassword], params[:userpasswordconfirm])
	if badinfo == true
		@error = true
		@message = "Username or email already taken... or your info could be bad... :S"
		erb :register
	elsif passsafe == false
		@error = true
		@message << ".... passwords dont match :("
		erb :register
	else
		createuser(params[:username], params[:userpassword], params[:useremail])
		@message = "Created user #{params[:username]}. Good luck!"
		erb :register
	end
end

get '/killme' do #kills it self, not so good
	Process.kill 9, Process.pid
end