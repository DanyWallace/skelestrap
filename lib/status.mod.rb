get '/status' do
  protected!
  @title = 'Status'
  @hostname = Stats.host
  @ram = Stats.ram
  @uptime = Stats.uptime
  erb :modstatus
end

get '/status/ram' do
  protected!
  @ram = Stats.ram
end

get '/status/users' do
  protected!
  erb :users
end

get '/status/uptime' do
  protected!
  @time = Stats.uptime
end

class Status

  def initialize
    print "ok.... \n"
  end

  def host
    hostname = `hostname`
    return "#{hostname}"
  end

  def ram (which = 0)
    ele = which
    ramget = `free -m`
    fetch = ramget.scan(/\d+/)
    usedram = fetch[1] #self explanatory
    maxram = fetch[0] #available*

    if (ele == 0) #pretty ram usage
      return "#{usedram + '/' + maxram}"
    elsif (ele == 1)
      return "#{usedram}"
    else
      return "#{maxram}"
    end

  end

  def uptime
    uptimeget = `uptime`
    fetch = uptimeget.match(/up(.+?),/).to_s
    fetch.gsub!("up", "")
    fetch.gsub!(',', '')
    return  "#{fetch}"
  end

end

Stats = Status.new
