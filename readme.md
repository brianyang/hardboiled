HardBoiled
===

A boilerplate for nodejs apps, optimized for heroku.

#What's this based on?

- twitter bootstrap
- coffeescript
- stylus
- jade
- express
- connect assets
- everyauth
- mongoose
- backbone
- mustache
- nowjs

#What's this do?

It's that same todo app example you see everywhere else. This one uses nowjs for Backbone.sync, and mongo on the backend for storing just about everything. And everyauth. And bootstrap. But all with coffeescript.

#Why do I want this?

You probably don't.

##Getting Started

	git clone git@github.com:proksoup/Hardboiled.git your_app_name
	cd ./your_app_name
	heroku create your_app_name --stack cedar --buildpack http://github.com/proksoup/heroku-buildpack-nodejs.git
	heroku addons:add mongolab:starter --app your_app_name
	git push heroku master

##Further reading

http://devcenter.heroku.com/articles/node-js
