# Skelestrap  
Skelestrap is a boilerplate/*example* made with sinatra applications that includes:  
* Uses **jwt** tokens for auth  
 * generates (unless you have one) a rsa key/pubkey to sign your tokens
* Authenticate users against a mysql database  
* Uses **bulma** as a **css framework**  

## To install:  
* Clone this repo
* Create a mysql database  
* Change main.ini values accordingly (it's your mysql user/db info)  

Then run the following  

`gem install bundler`  
`bundle install`  
`rake makedb`  
`rake run` OR `bundle exec ruby main.rb`  

When you run `rake makedb` this creates a user/group table and a new admin user (username: chief password: password), and a private/pub key if one doesn't already exist


I use this as a boilerplate for my personal projects.