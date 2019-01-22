include FileUtils::Verbose

post '/upload' do
	if authorized? && @rank.to_i >= 3
    	tempfile = params[:file][:tempfile]
    	filename = params[:file][:filename]
    	user_signature =  user_info(@user_name, 'Signature')
    	cp(tempfile.path, "public/files/#{user_signature}-#{filename}")
    	log = `echo "#{Time.now} - #{filename} by #{@user_name}" >> filelog.txt`
	else 
		"you can't upload because you got no permissions :S"
	end
end

#Verifies that it is an image, duh
def is_image? (tempfile, filename, username)
	types = ['png', 'jpg', 'gif', 'jpeg']
	if types.include? filename.split('.').last.to_s
		log = `echo "#{Time.now} - #{filename} by #{@user_name}: Is an Uploaded avatar." >> filelog.txt`
		return true
	else
		log = `echo "#{Time.now} - #{filename} by #{@user_name}: Didn't detect it as an image? split_filename:#{filename.split('.').last.to_s}" >> filelog.txt`
		return false
	end
end

# Avatars are uploaded and saved as *usersig*-filename.ext
post '/upload/avatar' do
	if authorized?
    	@tempfile = params[:file][:tempfile] 
    	@filename = params[:file][:filename]
    	@extension = @filename.split('.').last.to_s
    	if is_image?(@tempfile, @filename, @user_name) == true
    		user_signature =  user_info(@user_name, 'Signature')
    		avatar_file = "#{user_signature}-.#{@extension}"
    		cp(@tempfile.path, "public/avys/#{avatar_file}")
    		log = `echo "#{Time.now} - #{@filename} by #{@user_name} saved as #{avatar_file}" >> filelog.txt`
    		# Update user profile with new pic name
    		@@client.query("UPDATE Users SET Pic = '#{avatar_file}' WHERE Signature = '#{user_signature}'")
    		redirect to("/")
    	else
    		"That doesn't work"
    	end
	else 
		"Log in first?"
	end
end