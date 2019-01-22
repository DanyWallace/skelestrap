def passissafe(password, verification)
  if password == verification
    return true
  else
    return false
  end
end

def createuser(name, password, email, real_name, bio)
  name = name
  prepass = Digest::Whirlpool.hexdigest("#{password}")
  saltedpass = Digest::Whirlpool.hexdigest("#{name}#{prepass}")
  email = email
  @@client.query("INSERT INTO Users VALUES(NULL, '#{name}', '#{saltedpass}', '#{email}', '#{whirlGen(10)}', 3, 0, 10,'Newbie', 0, '#{real_name}', 'bio', 'Default.png')")
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
  result = @@client.query("Select * FROM Users WHERE Username = '#{@user}'").each(:as => :hash)[0]
  if result.empty?
    return false
  elsif result['Username'] == @user
    @attempt = Digest::Whirlpool.hexdigest("#{@passattempt}")
    salted = Digest::Whirlpool.hexdigest("#{@user}#{@attempt}")
    if salted == result['Password']
      return true
    else
      return false
    end
  end
end


def verify_user(code)
  user = @@client.query("Select * FROM Users WHERE Signature = '#{code}'").each(:as => :hash)
  if user.empty?
    return "No user found"
  elsif user[0]['Rank'] == 0
    @@client.query("UPDATE Users SET Rank = Rank + 1 WHERE Username = '#{user[0]['Username']}'")
    return "Perfect, verified."
  end
end

def user_info(user, element)
  if element == 'Password'
    return 'nope'
  elsif @user_name == user || @rank.to_i >= 9
    # if the info doesn't belong to you, you better be a high ranked user
    info = @@client.query("Select #{element} FROM Users WHERE Username = '#{user}'").each(:as => :array)
    info = info.join(", ")
    return info
  else
    return "You don't have permission or you're messing around too much>:D #{@rank}"
  end
end

def is_verified? (username)
  @rank = 10 # permission requirement for getting user info
  email = user_info(username, 'Email')
  verified_status = @@client.query("Select Rank FROM Users WHERE Email = '#{email}'").each(:as => :hash)
  if verified_status == nil
    log = `echo "Checked if #{username} is verified and its *false*" >> log.txt`
    return nil
  else
    log = `echo "Checked if #{username} is verified and its *true*" >> log.txt`
    return true
  end
end