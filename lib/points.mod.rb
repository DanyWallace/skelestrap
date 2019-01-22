def current_points
	points = @@client.query("SELECT Points FROM Users WHERE Username = '#{@user_name}'").each(:as => :array)
	points = points.join(", ")
	return points
end

def add_points(amount, user)
	@@client.query("UPDATE Users SET Points = Points + #{amount} WHERE Username = '#{user}'")
end

def get_points(user)
	@@client.query("SELECT Points FROM Users WHERE Username = '#{user}'")
end

get '/api/addpoints' do
	if @rank.to_i >= 9
		add_points(params[:amount], params[:username])
	else
		"Nope"
	end
end