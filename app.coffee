###
Error Handling

Catch uncaught errors
###
log_err = (err) ->
  to_output = '-----------------------------\n'
  to_output+= 'COMPLETE:\n ' + util.inspect err
  if typeof(err) is 'object' and err.stack
    to_output+='\nSTACK:\n' + err.stack
  to_output+= '\n-----------------------------'
  console.log to_output
process.on 'uncaughtException', log_err

###
Utilities

underscore, restler, util
###
restler = require 'restler'
_ = require 'underscore'
util = require 'util'


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

UserSchema = new Schema
  provider: String
  pid: String
  email: String
  name: String

User = mongoose.model 'User', UserSchema

###
Mongo Store

For all session data
###
mongostore = require 'connect-mongo'

session_store = new mongostore
  url: db_uri

###
Everyauth

###
everyauth = require 'everyauth'
findOrCreateUser = (promise, user) ->
  User.findOne
    provider: user.provider
    pid: user.id
  , (err, found_user) ->
    if err
      promise.fail err
    else if found_user
      promise.fulfill found_user
    else
      new_user = new User user
      new_user.save (err, saved_user) ->
        if err
          promise.fail err
        else
          promise.fulfill saved_user
conf = require './lib/conf'
everyauth.everymodule.findUserById (id, next) ->
  User.findById id, next

everyauth.openid.myHostname('http://local.host:3000').redirectPath('/').findOrCreateUser (session, userMetadata) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'openid'
    pid: userMetadata.claimedIdentifier
    email: userMetadata.email
    name: userMetadata.fullname
  promise

everyauth.facebook.appId(conf.fb.appId).appSecret(conf.fb.appSecret).redirectPath('/').scope('email').findOrCreateUser (session, accessToken, accessTokenExtra, fbUserMetadata) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'fb'
    pid: fbUserMetadata.id
    email: fbUserMetadata.email
    name: fbUserMetadata.name
  promise

everyauth.twitter.consumerKey(conf.twit.consumerKey).consumerSecret(conf.twit.consumerSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessSecret, twitUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'twit'
    pid: twitUser.id
    name: twitUser.name
  promise

everyauth.github.appId(conf.github.appId).appSecret(conf.github.appSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessTokenExtra, ghUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'github'
    pid: ghUser.id
    email: ghUser.email
    name: ghUser.name
  promise

everyauth.instagram.appId(conf.instagram.clientId).appSecret(conf.instagram.clientSecret).scope("basic").redirectPath('/').findOrCreateUser (sess, accessToken, accessTokenExtra, hipster) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'instagram'
    pid: hipster.id
    email: hipster.email
    name: hipster.name
  promise

everyauth.google.fetchOAuthUser((accessToken) ->
  promise = this.Promise()
  restler.get 'https://www.googleapis.com/userinfo/email', 
    query:
      oauth_token: accessToken
      alt: 'json'
  .on 'success',(data, res) ->
    oauthuser = 
      email: data.data.email
    promise.fulfill oauthuser
  .on 'error', (data, res) ->
    promise.fail data
  promise
).appId(conf.google.clientId).appSecret(conf.google.clientSecret).redirectPath('/').scope('https://www.googleapis.com/auth/userinfo.email').findOrCreateUser (sess, accessToken, extra, googleUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'google'
    pid: googleUser.id
    email: googleUser.email
  promise

everyauth.readability.consumerKey(conf.readability.consumerKey).consumerSecret(conf.readability.consumerSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessSecret, reader) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'readability'
    pid: reader.username
    name: reader.first_name + ' ' + reader.last_name
  promise


everyauth.linkedin.consumerKey(conf.linkedin.apiKey).consumerSecret(conf.linkedin.apiSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessSecret, linkedinUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'linkedin'
    pid: linkedinUser.id
    name: linkedinUser.firsName + ' ' + linkedinUser.lastName
    email: linkedinUser.email
  promise

everyauth.dropbox.consumerKey(conf.dropbox.consumerKey).consumerSecret(conf.dropbox.consumerSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessSecret, dropboxUserMetadata) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'dropbox'
    pid: dropboxUserMetadata.uid
    name: dropboxUserMetadata.display_name
  promise

everyauth.tumblr.consumerKey(conf.tumblr.consumerKey).consumerSecret(conf.tumblr.consumerSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessSecret, tumblrUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'tumblr'
    pid: tumblrUser.name
    name: tumblrUser.name
  promise

everyauth.box.apiKey(conf.box.apiKey).redirectPath('/').findOrCreateUser (sess, authToken, boxUser) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'box'
    pid: boxUser.id
    email: boxUser.user_email
  promise

everyauth.evernote.oauthHost(conf.evernote.oauthHost).consumerKey(conf.evernote.consumerKey).consumerSecret(conf.evernote.consumerSecret).redirectPath('/').findOrCreateUser (sess, accessToken, accessTokenExtra, enUserMetadata) ->
  promise = this.Promise()
  findOrCreateUser promise,
    provider: 'evernote'
    pid: enUserMetadata.userId
    name: enUserMetadata.userId
  promise



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
  }), everyauth.middleware()

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

everyauth.helpExpress app


###
NowJS

###
nowjs = require 'now'
everyone = nowjs.initialize app,
  socketio:
    transports: ['xhr-polling']

get_owner_id = (from_user) -> if from_user.session and from_user.session.auth then from_user.session.auth.userId else from_user.cookie['connect.sid']

nowjs.on 'connect', () ->
  nowjs.getGroup(get_owner_id @.user).addUser @.user.clientId

nowjs.on 'disconnect', () ->
  nowjs.getGroup(get_owner_id @.user).removeUser @.user.clientId

everyone.now.Todo_call = (method, attributes, next) ->
  owner_id = get_owner_id @.user
  group = nowjs.getGroup owner_id
  others = group.exclude @.user.clientId

  if method is 'read'
    await Todo.find
      owner_id: owner_id
    , Todo.visible_fields, {}, defer err, todos
    next todos

  if method is 'create'
    todo = new Todo
      text: attributes.text
      order: attributes.order
      done: attributes.done
      owner_id: owner_id
    await todo.save defer err
    others.now.Todo_add todo
    next todo
  
  if method is 'delete'
    await Todo.findOne
      _id: attributes._id
      owner_id: owner_id
    , Todo.visible_fields, defer err, todo
    if todo
      todo.remove()
      others.now.Todo_remove todo
      next todo
  
  if method is 'update'
    await Todo.findOne
      _id: attributes._id
      owner_id: owner_id
    , Todo.visible_fields, defer err, todo
    for key,value of attributes
      todo[key] = value
    await todo.save defer err
    others.now.Todo_set todo
    next todo

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
  res.render 'dashboard',
    layout: 'layout-fluid'

app.get "/dashboard", must_be_logged_in, (req, res, next) ->
  res.render 'dashboard',
    layout: 'layout-fluid'

app.get '*', (req, res, next) ->
  res.statusCode = 404
  res.render '404'

###
Wrap Up

###
app.listen process.env.PORT or 4000