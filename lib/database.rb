require 'inifile'
require 'mysql2'
require 'digest/whirlpool'

load 'lib/utils.rb'

puts "We're now building your database :D"

settings = IniFile.load('main.ini')

@client = Mysql2::Client.new(
  :host => settings['db']['host'],
  :username => settings['db']['username'],
  :database => settings['db']['database'],
  :password => settings['db']['password']
)

def createetc
  @client.query ("CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY AUTO_INCREMENT,
        Username TEXT, Password TEXT, Email TEXT, Signature TEXT,Usergroup int, Rank int, Points int, Title TEXT, Verified int, Name TEXT, Bio TEXT, Pic TEXT )")
  puts 'Created Users table'
  @client.query ("CREATE TABLE IF NOT EXISTS Groups(Id INTEGER PRIMARY KEY AUTO_INCREMENT,
        Groupname TEXT, Email TEXT, Title TEXT )")
  puts 'Created Groups table'
  @client.query ("CREATE TABLE IF NOT EXISTS Containers(Id INTEGER PRIMARY KEY AUTO_INCREMENT, Name TEXT, Owner TEXT, Type TEXT, Creation int, Expiration int, Port TEXT, Url TEXT, Cost int, Traffic int, Hits int, Status TEXT )")
  puts "Created Containers tabe"
  #@client.query ("CREATE TABLE IF NOT EXISTS Verification` ( id INT NOT NULL , user TEXT, sign TEXT, type TEXT, value TEXT)")
  #puts 'Created verification tables'
end

def addadmin
  settings = IniFile.load('main.ini')
  username = "#{settings['mainuser']['user']}"
  real_name = "#{settings['mainuser']['real_name']}"
  password = "#{settings['mainuser']['password']}"
  email = "#{settings['mainuser']['email']}"
  rank = "#{settings['mainuser']['rank']}"
  info = "#{settings['mainuser']['bio']}"
  picture = "#{settings['mainuser']['pic']}"
  prepass = Digest::Whirlpool.hexdigest("password")
  saltedpass = Digest::Whirlpool.hexdigest("#{username}#{prepass}")
  @client.query("INSERT INTO Users VALUES(NULL, 'chief', '#{saltedpass}', '#{email}', '#{whirlGen(10)}', 1, #{rank}, 10, 'Master', 1, '#{real_name}', '#{info}', '#{picture}')")
  puts "Created admin account: user:#{username} password: #{password}"
end

def createsigningkeys
  if File.file?('lib/app.rsa')
    return nil
  end
  genrate = `openssl genrsa -out lib/app.rsa 2048`
  pubcreate = `openssl rsa -in lib/app.rsa -pubout > lib/app.rsa.pub`
  puts 'created rsa keys'
end

createetc
createsigningkeys
addadmin
