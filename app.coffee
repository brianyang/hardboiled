
###
Redis

Used for storing session data perhaps?
###
connect = require 'connect'
redis_store = require('connect-redis') connect

redis_options =
  host: 'localhost'
  port: 6379

if process.env.REDISTOGO_URL
  redis_options = 
    host: process.env.REDISTOGO_URL.replace /.*@([^:]*).*/ig, '$1'
    port: process.env.REDISTOGO_URL.replace /.*@.*:([^\/]*).*/ig, '$1'
    pass: process.env.REDISTOGO_URL.replace /.*:.*:(.*)@.*/ig, '$1'

session_store = new redis_store redis_options

###
Mongo

###
mongoose = require 'mongoose'

db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/boilerplate'

mongoose.connect db_uri

Schema = mongoose.Schema
ObjectId = mongoose.SchemaTypes.ObjectId

UserSchema = new Schema({})


###
Mongoose Auth

###
conf = require './conf'
everyauth = require 'everyauth'
Promise = everyauth.Promise
everyauth.debug = true
User = undefined

mongooseAuth = require 'mongoose-auth'

UserSchema.plugin mongooseAuth,
  everymodule:
    everyauth:
      User: ->
        User

  facebook:
    everyauth:
      myHostname: "http://local.host:3000"
      appId: conf.fb.appId
      appSecret: conf.fb.appSecret
      redirectPath: "/"

  twitter:
    everyauth:
      myHostname: "http://local.host:3000"
      consumerKey: conf.twit.consumerKey
      consumerSecret: conf.twit.consumerSecret
      redirectPath: "/"

  password:
    loginWith: "email"
    extraParams:
      phone: String
      name:
        first: String
        last: String

    everyauth:
      getLoginPath: "/login"
      postLoginPath: "/login"
      loginView: "login.jade"
      getRegisterPath: "/register"
      postRegisterPath: "/register"
      registerView: "register.jade"
      loginSuccessRedirect: "/"
      registerSuccessRedirect: "/"

  github:
    everyauth:
      myHostname: "http://local.host:3000"
      appId: conf.github.appId
      appSecret: conf.github.appSecret
      redirectPath: "/"

  instagram:
    everyauth:
      myHostname: "http://local.host:3000"
      appId: conf.instagram.clientId
      appSecret: conf.instagram.clientSecret
      redirectPath: "/"

  google:
    everyauth:
      myHostname: "http://localhost:3000"
      appId: conf.google.clientId
      appSecret: conf.google.clientSecret
      redirectPath: "/"
      scope: "https://www.google.com/m8/feeds"

mongoose.model "User", UserSchema
User = mongoose.model("User")


###
Express

###
express = require 'express'
connect_assets = require 'connect-assets'

app = express.createServer express.bodyParser(), express.methodOverride(), express.static(__dirname + "/assets"), express.cookieParser(), connect_assets(), express.session({
    secret: 'how now brown cow'
    store: session_store
    cookie:
      maxAge: 86400000 * 14
  }), mongooseAuth.middleware()

app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.set 'view options',
    req: {}
    # Cut off at 60 characters 
    title: 'Boilerplate | a plate, for boiling'
    # Cut off at 140 to 150 characters
    description: 'You should probably update this.'

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

mongooseAuth.helpExpress app

###
Mail

Method A) in /etc/launchd.conf
  setenv SENDGRID_USERNAME your_username
  setenv SENDGRID_PASSWORD your_password
  setenv SENDGRID_DOMAIN your_domain

Method B) modify below
  user: process.env.SENDGRID_USERNAME or your_username
  pass: process.env.SENDGRID_PASSWORD or your_password
  domain: process.env.SENDGRID_DOMAIN or your_domain


###
nodemailer = require 'nodemailer'

nodemailer.SMTP = 
  host: 'smtp.sendgrid.net'
  port: 25
  use_authentication: true
  user: process.env.SENDGRID_USERNAME
  pass: process.env.SENDGRID_PASSWORD
  domain: process.env.SENDGRID_DOMAIN

console.log process.env.SENDGRID_USERNAME

nodemailer.send_mail
  sender: 'help@cards.ly'
  to: 'elspoono@gmail.com'
  subject: 'Test Email'
  body: 'I am just testing this nodemailer thing out.'

###
Routes

We pass the "req" object every time to make it easy to add more variables for jade
###
app.get "/", (req, res, next) ->
  res.render 'index',
    req: req

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.get '*', (req, res, next) ->
  res.send '',
    Location:'/'
  , 302

###
Wrap Up

###
app.listen process.env.PORT or 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
