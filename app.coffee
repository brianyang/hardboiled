###
Utilities

underscore, restler
###
restler = require 'restler'
_ = require 'underscore'


###
Mongo

Getting mongoose started
###
mongoose = require 'mongoose'

db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/boilerplate'

mongoose.connect db_uri

Schema = mongoose.Schema
ObjectId = mongoose.SchemaTypes.ObjectId

TodoSchema = new Schema
  owner_id: String
  text: String
  order: Number
  done: Boolean
Todo = mongoose.model 'Todo', TodoSchema

Todo.visible_fields = ['text', 'order', 'done']

UserSchema = new Schema({})

###
Mongo Store

For all session data
###
mongostore = require 'connect-mongo'

session_store = new mongostore
  url: db_uri

###
Mongoose Auth

For the auth session data.
- accessible in jade templates as everyauth
- accessible in express routes as req.user
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
    # Cut off at 60 characters 
    title: 'Hardboiled | a plate, for boiling'
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
NowJS

###
nowjs = require 'now'
everyone = nowjs.initialize app

nowjs.on 'connect', () ->

  owner_id = @.user.cookie['connect.sid']
  owner_id = @.user.auth.userId if @.user.auth

  nowjs.getGroup(owner_id).addUser @.user.clientId

nowjs.on 'disconnect', () ->

  owner_id = @.user.cookie['connect.sid']
  owner_id = @.user.auth.userId if @.user.auth

  nowjs.getGroup(owner_id).removeUser @.user.clientId

everyone.now.Todo = (method, attributes) ->

  owner_id = @.user.cookie['connect.sid']
  owner_id = @.user.auth.userId if @.user.auth

  group = nowjs.getGroup(owner_id).now

  if method is 'read'
    await Todo.find
      owner_id: owner_id
    , Todo.visible_fields, {}, defer err, todos
    @.now.read todos

  if method is 'create'
    todo = new Todo
      text: attributes.text
      order: attributes.order
      done: attributes.done
      owner_id: owner_id
    await todo.save defer err
    @.now.create todo
  
  if method is 'delete'
    await Todo.findOne
      _id: attributes._id
      owner_id: owner_id
    , Todo.visible_fields, defer err, todo
    todo.remove()
    @.now.delete todo
  
  if method is 'update'
    await Todo.findOne
      _id: attributes._id
      owner_id: owner_id
    , Todo.visible_fields, defer err, todo
    for key,value of attributes
      todo[key] = value
    await todo.save defer err
    @.now.update todo

###
Mail

SendGrid Example:
  restler.post 'https://sendgrid.com/api/mail.send.json',
    data:
      api_user: process.env.SENDGRID_USERNAME
      api_key: process.env.SENDGRID_PASSWORD
      subject: 'Test Email'
      text: 'This is only a test'
      to: 'elspoono@gmail.com'
  .on 'complete', (data, res) ->
    console.log data

###

###
Jade Middleware

###
must_be_logged_in = (req, res, next) ->
  if req.user
    next()
  else
    res.send '',
      'Location': '/'
    , 302

redirect_if_logged_in = (req, res, next) ->
  if req.user
    res.send '',
      'Location': '/dashboard'
    , 302
  else
    next()


###
Jade Routes

We pass the "req" object every time to make it easy to add more variables for jade
###
app.get "/", redirect_if_logged_in, (req, res, next) ->
  res.render 'index'

app.get "/demo",redirect_if_logged_in, (req, res, next) ->
  res.render 'demo'

app.get "/dashboard", must_be_logged_in, (req, res, next) ->
  res.render 'dashboard'

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

###
Wrap Up

###
app.listen process.env.PORT or 4000