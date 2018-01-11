def verifydb
	@@client.query ("CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY AUTO_INCREMENT, 
        Username TEXT, Password TEXT, Email TEXT, Usergroup int, Rank int, Title TEXT )")
end

def passissafe(password, verification)
	if password == verification
		return true
	else
		return false
	end
end

def createuser(name, password, email)
	@name = name
	prepass = Digest::Whirlpool.hexdigest("#{password}")
	@saltedpass = Digest::Whirlpool.hexdigest("#{name}#{prepass}")
	@email = email
	@@client.query("INSERT INTO Users VALUES(NULL, '#{@name}', '#{@saltedpass}', '#{@email}', 3, 1, 'Newbie' )")
end

def isinfocorrect(name, email)
	@name = name
	@dupeuser = false
	@dupeemail = nil
	result = @@client.query("SELECT * FROM Users WHERE Username = '#{@name}'").each(:as => :hash)
	#logd = `echo "\n//result query:// #{result} //end//" >> log.txt`
	if result[0] == nil
		@dupeuser = false
	elsif result[0]['Username'] == @name
		@dupeuser = true
		#print "Username exists\n"
	end
	@email = email
	result = @@client.query("Select * FROM Users WHERE Email = '#{@email}'").each(:as => :hash)
	if result[0] == nil
		@dupeemail = false
	elsif result[0]['Email'] == @email
		@dupeemail = true
		#print "Email exists\n"
	end
	if (@dupeuser == true) or (@dupeemail == true)
		return true
	elsif @email.include?('@') == false
		return true
	else
		return false
	end
		
end

def trylogin (name, password)
	@user = name
	@passattempt = password
	result = @@client.query("Select * FROM Users WHERE Username = '#{@user}'").each(:as => :hash)
	if result.empty?
		return false
	elsif result[0]['Username'] == @user
		@attempt = Digest::Whirlpool.hexdigest("#{@passattempt}")
		salted = Digest::Whirlpool.hexdigest("#{@user}#{@attempt}")
		if salted == result[0]['Password']
			return result[0]['Id']
		else
			return false
		end
	end
end