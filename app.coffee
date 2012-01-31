#Modules

express = require 'express'
nodemailer = require 'nodemailer'

app = module.exports = express.createServer()

#Configuration

app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require("connect-assets")()
  app.use app.router
  app.use express.static(__dirname + "/assets")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()


#Mongo Schemas


#Routes
app.get "/", (req, res, next) ->
  res.render 'index',
    req: req



app.get '*', (req, res, next) ->
  res.send '',
    Location:'/'
  , 302

app.listen process.env.PORT or 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
