---
layout: post
title:  "So what is this about?"
description: "First post with any info"
date:   2018-12-28 12:00:00 -0800
categories: meta  
tags: news
---

This is about having fun.  
Skeleton is divided into multiple modules, by it self it's only supposed to manage users with a mysql db and jwt for cookies. Ironically rack cookies are encrypted which makes it useless as normal auth, but when you release some kind of api, jwt shines.
It offers:
* Sinatra  as a web framework
* MySql as storage
* jwt for auth
* jekyll - for a blog*
* IPs are checked against a fraud database 
* Email verification

## Notes  & specs
<hr>

### Email
You can set your smtp details on main.ini, when an account is made a verification link is also sent.

### Blog

Sites friles from jekyll are found on jekyll/_site, what happens here is that everytime you request to '/blog/*', w.e file you requested gets sent by sinatra. It defaults to index.html, this is actually functioning as an http server for jekyll.

There's a few consand pros  with this tho.

**+** Static files delivery scales better than a escalator.  
**-** Site needs to be rebuilt everytime there is a post.  
**-** As for the current release, you have to create category/tag pages manually*  

It takes me 1-4 seconds to rebuild the site on the slowest 4th gen intel cpu ever, i3 4012y @ 1.5ghz

* If you wish for a page that displays, tags for example, create a new html files with the tag name that you want indexed like this:

jekyll/tag/TAGNAME.html:

	---  
	layout: tagpage  
	tag: TAGNAME  
	---

Replace TAGNAME obviously.

### Fraud checking
The function ip_info(ip) returns a value betwen 0.0-1, if 1 then we got a really fishy ip, most likely from a server or some datacenter subnet.
This uses the free version of <a href="https://www.nofraud.com/"> nofraud's</a> old api (no docs XD).
Also you can use it 500 times a day as a soft limit imposed by them.

You can set the maximum danger/fishyness level on main.ini, I'd leave it at 0.8max to try and avoid as many false positives, and avoiding all datacenter ips at the least.


### Server status
As of now, it only displays current ram usage and uptime, nothing else.

## What is lacking? And what is being worked on.
<hr>
* Options to manage user accounts, another table will be created so one can choose between accounts that hold real info (name and such) or just plain user/email/password convos.
* Discourse SSO **&** shared sessionsis a WIP, I do have a working prototype of pure SSO, it just isn't integrated into master because of current resource constrictions (I don't have a spare docker-able machine with 1.5gb+ ram for discourse's container).  
* Wiki integration, currently I'm working on integrating gollum into this, I have a working user system but so far I'm not aware on  how to properly share sessions between sinatra apps. The idea is using jwt between skeleton and gollum to verify a current session instead of sharing rack secrets thanks to <a href="https://martinfowler.com/articles/session-secret.html">this post.</a> 

## Some credits:
This jekyll layout is based on <a href="https://github.com/erayaydin/jekyll-bulma%22">erayaydin's jekyll bulma theme</a>, obviously **much** different.  But this did save me some time. The header was removed, this now category/tags support, and a completly different frontpage/posts layout. Including the weird sidebar. Here is the <a href="https://era.yayd.in/jekyll-bulma/">original:</a>
<img src="http://i.imgur.com/hIfZedI.png">