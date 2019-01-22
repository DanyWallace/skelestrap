require 'active_support/all'

# Valid Statuses:
# Enabled = In db but has not been created
# Stopped = Has been created but is not running
# Disabled = Duh
# Running = Up and running, duh

#Sudo rights are required to reload nginx after creating a conf.

settings = IniFile.load('main.ini')

@root_path = settings['ghost']['path']


def current_settings
	return IniFile.load('main.ini')
end

# checks if a port is taken before giving it, duh
def port_taken? (port)  # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
  netstat = `lsof -i -P -n | grep ':#{port}'`
  if netstat.include? '(LISTEN)'
     true
  else
    false
  end
end

def free_port (start_number, amount) # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
  port = start_number + rand(amount)
  while port_taken?(port) == true
    port += 1
  end
  return port
end

def container_port_taken? (port) # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
	if @@client.query("Select * FROM Containers WHERE Port = '#{port}'").each(:as => :hash).empty?
		false
	else
		true
	end
end

def free_port_container (start_number, amount) # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
	port = start_number + rand(amount)
	while container_port_taken?(port) == true
		port += 1
	end
	return port
end

def nginx (container_name, url, port)
nginx_conf = <<NGINX_CONF
server {
    listen 80;
    server_name #{url};

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header HOST $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://127.0.0.1:#{port};
        proxy_redirect off;
    }
}
NGINX_CONF
return nginx_conf
end

puts free_port(4566, 2)

#Initialize with class(username, 0)
#In the future you will init with 'First'/'All'/'Name' as valid arguments
class Ghost_instance
	def initialize (username, which = 0) # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
		@user_owner = username
		@which = which
		@root_path = current_settings['ghost']['path']
	end

	def info
		 result = @@client.query("Select * FROM Containers WHERE Owner = '#{@user_owner}'").each(:as => :hash)
		 if result.empty?
		 	return "Don't have any containers"
		 else
		 	return result
		 end
	end

	def enabled?
		property = info
		if property[0]['Status'] == 'Enabled' || property[0]['Status'] == 'Started'
			return true
		else 
			return false
		end
	end

	def create (app_name, url = nil) # !> parentheses after method name is interpreted as an argument list, not a decomposed argument
		creation_time = Time.now.to_i
		expiration = creation_time + 7.days
		port = free_port_container(1100, 500) # assigns a random 'unusued' port between 1100-11500, 
		container_name = app_name
		application_type = 'Ghost'
		owner = @user_owner
		#true_url = url
		#url = "127.0.0.1:#{port}"
		cost = 0



		#make user folder, overwrite as true is temp. while in dev
		overwrite = true
		if overwrite == true
			`rm -rf #{@root_path}/#{container_name}-ghost #{@root_path}/#{container_name}-ghost.access.log #{@root_path}/nginx_confs/#{container_name}-ghost.conf`
			`mkdir #{@root_path}/#{container_name}-ghost`
			`touch #{@root_path}/#{container_name}.access.log`
		else
			`touch #{@root_path}/#{container_name}.access.log` #create log file
			`mkdir #{@root_path}/#{container_name}-ghost` 
			`touch #{@root_path}/nginx_confs/#{container_name}-ghost.conf && echo #{nginx_conf} >> #{@root_path}/nginx_confs/#{container_name}-ghost.conf`
		end
		#reload nginx
		#`sudo service nginx reload`

		#add to db
		@@client.query("INSERT INTO Containers VALUES(NULL, '#{container_name}', '#{owner}', '#{application_type}', #{creation_time}, #{expiration.to_i}, '#{port}', '#{url}', #{cost}, 0, 0, 'Ready')")
		log = "Created #{container_name} for #{owner}: creating: #{creation_time}\nexpiration:#{expiration.to_i}\nport:#{port}\nurl:#{url}\ncost:#{cost}"
		puts log
		File.write("#{@root_path}/#{container_name}.txt", log)
	end

	def stop(id = 0)
		property = info
		container_name = property[id]['Name']
		if property[id]['Status'] == 'Started'
			`docker stop #{container_name}`
			@@client.query("UPDATE Containers SET Status = 'Stopped' WHERE Name = '#{container_name}'")
			return true
		else
			return false
		end
	end

	def delete(id = 0) #names cannot be used again so far
		puts "get ready..."
		#Delete ghost folder & nginx config, doesn't delete the access log
		`rm -rf {@root_path}/#{info[id]['Name']}-ghost {@root_path}/nginx_confs/#{info[id]['Name']}-ghost.conf`
		#Change status in database
		@@client.query("UPDATE Containers SET Status = 'Disabled' WHERE Name = '#{info[id]['Name']}'")
		#stop and delete container
		`docker stop #{info[id]['Name']} && docker rm #{info[id]['Name']}`
	end

	def start(id = 0)
		property = info
		container_name = property[id]['Name']
		if property[id]['Status'] == 'Stopped'
			@@client.query("UPDATE Containers SET Status = 'Started' WHERE Name = '#{container_name}'")
			return `docker start #{container_name}`
		elsif property[id]['Status'] == 'Ready'
			puts "creating...."
			@@client.query("UPDATE Containers SET Status = 'Started' WHERE Name = '#{container_name}'")
			#`service nginx reload`
			#nginx conf
			nginx_conf = nginx(container_name, property[id]['Url'], property[id]['Port'])
			File.write("#{@root_path}/nginx_confs/#{container_name}-ghost.conf", nginx_conf)
			#reload nginx
			`sudo service nginx reload`
			return `docker run -d --name #{container_name} -p #{property[id]['Port']}:2368 -v /home/captain/sites/#{property[0]['Name']}-ghost:/var/lib/ghost/content -e url=http://#{property[id]['Url']} ghost:2-alpine`
		else
			return "Your instance isn't right or already started"
		end
	end
end



def list_blogs
	my_containers = Ghost_instance.new(@user_name)
	@all = ""
	my_containers.info.each_with_index do |info, index|
	creation = Time.at(info['Creation']).strftime('%D %H:%M')
	expiration = Time.at(info['Creation']).strftime('%D %H:%M')
	list_layout = <<LIST_LAYOUT
<tr>
     <td>#{index}</td>
    <td>#{info['Name']}</td>
    <td>#{info['Url']}</td>
    <td>#{info['Cost']}</td>
    <td>#{creation}</td>
    <td>#{expiration}</td>
    <td><div class="button">Delete</div></td>
    </tr>\n
LIST_LAYOUT
	@all << list_layout
	end
	return @all
end

def list_blogs_active
	my_containers = Ghost_instance.new(@user_name)
	@@all = ""
	my_containers.info.each_with_index do |info, index|
	creation = Time.at(info['Creation']).strftime('%D %H:%M')
	expiration = Time.at(info['Creation']).strftime('%D %H:%M')
	@list_layout = <<LIST_LAYOUT
<tr>
     <td>#{index}</td>
    <td>#{info['Name']}</td>
    <td>#{info['Url']}</td>
    <td>#{info['Cost']}</td>
    <td>#{creation}</td>
    <td>#{expiration}</td>
    <td>#{info['Status']}</td>
    <td><a href="/blogs/start/#{index}"><div class="button is-green">Start</div></a></td>
    <td><a href="/blogs/delete/#{index}"><div class="button is-danger">Delete</div></a></td>
    </tr>\n
LIST_LAYOUT
	if info['Status'] == 'Ready' || info['Status'] == 'Started'
		@@all << @list_layout
	else
		"hello"
	end
	end
	return @@all
end


def return_all_my_blogs #dev
	my_containers = Ghost_instance.new(@user_name)
	@blog_list = ""
	my_containers.info.each_with_index do |item, index|
	blog =  "#{index} #{item['Name']} #{item['Port']} #{item['Status']}"
	@blog_list << blog
	end
	return @blog_list
end

get '/blogs' do
	protected!
	authorize!
	@my_blogs = return_all_my_blogs
	@my_containers = Ghost_instance.new(@user_name)
	erb :containers
end

get '/blogs/create' do
	protected!
	authorize!
	erb :createghost
end

get '/blogs/delete/:id' do
	protected!
	authorize!
	my_containers = Ghost_instance.new(@user_name)
	my_containers.delete(params[:id].to_i)
	redirect to("/blogs")
end

get '/blogs/start/:id' do
	protected!
	authorize!
	my_containers = Ghost_instance.new(@user_name)
	my_containers.start(params[:id].to_i)
	redirect to("/blogs")
end

post '/blogs/create/' do
	protected!
	authorize!
	my_containers = Ghost_instance.new(@user_name)
	my_containers.create(params[:Name], params[:Url])
	redirect to("/blogs")
end



get '/blogs/stats' do
	protected!
	authorize!
	erb :ghost_stats
end