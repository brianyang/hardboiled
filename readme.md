HardBoiled
===

A boilerplate for nodejs apps, optimized for heroku.

#What's Included

- twitter bootstrap
- connect assets
- coffeescript
- stylus
- jade
- express
- mongoose
- nodemailer


##Getting Started

	git clone git@github.com:proksoup/Hardboiled.git your_app_name
	cd ./your_app_name
	heroku create your_app_name --stack cedar --buildpack http://github.com/proksoup/heroku-buildpack-nodejs.git
	heroku addons:add redistogo:nano --app your_app_name
	heroku addons:add mongolab:starter --app your_app_name
	git push heroku master