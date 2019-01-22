get '/user/verify/:verification' do
  verify_user(params[:verification])
  redirect to("/")
end

get '/user/resend_email' do
	if authorized?
		verification_email(@user_name)
		redirect to ("/")
	else
		"You might need to log in first"
	end
end

get '/user/info/:username/:element' do
	protected!
	if authorized?
		"#{user_info(params[:username], params[:element])}"
	else
		"You might need to log in first"
	end
end

get '/user/session/jwt/' do # sends the current token to sso_turn_url, dangerous? yeah, let's bet on signing
	protected!
	if authorized?
		redirect to("#{params[:return_sso_url]}?jwt=#{@token}")
	else
		"you don't have a valid token you twat"
	end	
end