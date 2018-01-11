require 'inifile'
require 'mysql2'
require 'digest/whirlpool'

puts "We're now building your database :D"

settings = IniFile.load('main.ini')

@@client = Mysql2::Client.new(
	:host => "#{settings['db']['host']}",
	:username => "#{settings['db']['username']}",
	:database => "#{settings['db']['database']}",
	:password => "#{settings['db']['password']}" )

def createuserstable
	@@client.query ("CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY AUTO_INCREMENT, 
        Username TEXT, Password TEXT, Email TEXT, Usergroup int, Rank int, Title TEXT )")
	puts "Created Users table"
end

def creategroups
	@@client.query ("CREATE TABLE IF NOT EXISTS Groups(Id INTEGER PRIMARY KEY AUTO_INCREMENT, 
        Groupname TEXT, Email TEXT, Title TEXT )")
	puts 'Created Groups table'
end

def addadmin
	name = "chief"
	password = "password"
	email = "masteratemail.com"
	prepass = Digest::Whirlpool.hexdigest("password")
	saltedpass = Digest::Whirlpool.hexdigest("#{name}#{prepass}")
	@@client.query("INSERT INTO Users VALUES(NULL, 'chief', '#{saltedpass}', '#{email}', 1, 1, 'Master' )")
	puts "Created admin account: user:#{name} password: #{password}"
end

def createsigningkeys
	if File.file?('lib/app.rsa')
		return nil
	end
	genrate = `openssl genrsa -out lib/app.rsa 2048`
	pubcreate = `openssl rsa -in lib/app.rsa -pubout > lib/app.rsa.pub`
	puts 'created rsa keys'
end

createuserstable
creategroups
createsigningkeys
addadmin
