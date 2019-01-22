# Skelestrap  
Skelestrap is a boilerplate/*example* made with sinatra applications that includes:  
* Uses **jwt** tokens for auth  
    * generates (unless you have one) a rsa key/pubkey to sign your tokens
* Authenticate users against a mysql database  
    * Checks ip against nofraud.org during signup
    * Email verification
* Uses **bulma** as a **css framework**  
* Random web applications are bundled as `name.mod.rb` inside the lib directory, you can safely delete these as they're just in because.


## To install:  
* Clone this repo
* Create a mysql database  
* Change main.ini values accordingly  

Then run the following  

`gem install bundler`  
`bundle install`  
`rake makedb`  
`rake run` OR `bundle exec ruby main.rb`  

When you run `rake makedb` this creates a user/group table and a new admin user (username: chief password: password), and a private/pub key if one doesn't already exist


I use this as a boilerplate for my personal projects.

# Included addons

## Blog Functionality
skeleton actually just loads any html files within `jekyll/_site`, this can be changed easily, this means you can swap the blog theme for anything (as long as it doesn't interfere with bulma).

## Status
Shows random computer stats running around (ram, uptime, etc)
* To add: hostname,  ip(public/lan/gateway), cpu usage (chart)
    * Task runner(?)

# To do:
* Limit login attempts per ip
* Captcha support(?)
* Self backup functionality
* Discourse sso + shared sessions
* Wiki system (from discourse[?])
