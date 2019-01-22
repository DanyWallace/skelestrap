settings = IniFile.load('main.ini')

@@client = Mysql2::Client.new(
  :host => settings['db']['host'],
  :username => settings['db']['username'],
  :database => settings['db']['database'],
  :password => settings['db']['password'],
  :reconnect => true
)

@url = settings['site']['url'].to_s
@@site_name = settings['site']['name']

#Here are a bunch of RNGs for your'needs'.
#The only true random
def fetchFromRandom(maxlength)
  fetcher = Mechanize.new
  fetch = fetcher.get("https://www.random.org/strings/?num=1&len=#{maxlength}&digits=on&upperalpha=on&loweralpha=on&format=html&rnd=new")
  fetch.parser.xpath('/html/body/div/pre').text
end

def numConsonantGen(maxlength)
  holdabc = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
  string = (0..maxlength).map { holdabc[rand(holdabc.length)] }.join
  string
end

def whirlGen(maxlength)
  holdabc = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
  string = (0..27).map { holdabc[rand(holdabc.length)] }.join
  stringwhirled = Digest::Whirlpool.hexdigest(string)
  stringwhirled[0..maxlength]
end

def numGen(maxlength)
  holdabc = [(0..9)].map(&:to_a).flatten
  string = (0..maxlength).map { holdabc[rand(holdabc.length)] }.join
  string
end

def ip_info(ip)
  url = URI.parse("http://api.nofraud.co/ip.php?ip=#{ip}")
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end
  res.body
end

