express = require("express")
passport = require("passport")
routes = require("./routes")
http = require("http")
path = require("path")
stylus = require('stylus')

app = express()
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.logger()
app.use express.cookieParser()
app.use express.urlencoded()
app.use express.json()
app.use express.session(secret: "keyboard cat")
app.use passport.initialize()
app.use passport.session()
app.use express.bodyParser()
app.use express.methodOverride()

app.use (req, res, next)->
  user_session = if req.session.name
    {
      id: req.session.uid
      name: req.session.name
      pictureUrl: req.session.pictureUrl
      authId: req.session.authId
      complete: req.session.complete
    }
  else
    null

  res.locals.user_session = user_session
  next()

app.use app.router

app.use stylus.middleware(
	src: __dirname + '/views'
	dest: __dirname + '/public'
)

app.use express.static(__dirname + "/public")

app.get '/status', (req, res)->
  res.send 'up and running!'

app.get "/", (req, res)->
  res.render('index', { title: 'Express'})

baseUrl = 'http://hackr-trackr.herokuapp.com'

setSession = (req, accessToken, user)->
  req.session.accessToken = accessToken
  req.session.uid = user._id.str
  req.session.authId = user.auth.id
  req.session.name = user.name
  req.session.pictureUrl = user.pictureUrl
  req.session.complete = user.complete?

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/"

###############Passport#################

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

###############LinkedIn#################
###
linkedin = require 'passport-linkedin-oauth2'
LinkedinStrategy = linkedin.Strategy
LINKEDIN_CLIENT_ID = "75agqd2lrg9ozy"
LINKEDIN_CLIENT_SECRET = "0c1wXQ6vuAfoTN9Z"

passport.use new LinkedinStrategy(
  clientID: LINKEDIN_CLIENT_ID
  clientSecret: LINKEDIN_CLIENT_SECRET
  callbackURL: "#{baseUrl}/linkedin/auth/callback"
  passReqToCallback: true
, (req, accessToken, refreshToken, profile, done) ->
    require("./models/user").upsert 'linkedin', accessToken, profile, (err, data)->
      console.log err if err?
      setSession req, accessToken, data
      done null, profile
)

app.get "/linkedin/login", (req, res) ->
  user = req.user
  return res.send user if user?
  res.send '<a href="/linkedin/auth">Login with LinkedIn</a>'

app.get "/linkedin/account", ensureAuthenticated, (req, res) ->
  res.send req.user


app.get "/linkedin/auth", passport.authenticate("linkedin",
  state: "SOME STATE"
), (req, res) ->

app.get "/linkedin/auth/callback", passport.authenticate("linkedin",
  failureRedirect: "/linkedin/login"
), (req, res) ->
  res.redirect "/"

app.get "/linkedin/logout", (req, res) ->
  req.logout()
  req.session.destroy()
  console.log "logging out", req.session
  res.redirect "/"

###
#############Eventbrite############

eventbrite= require 'passport-eventbrite-oauth'
EventbriteStrategy = eventbrite.OAuth2Strategy
EVENTBRITE_CLIENT_ID = 'RWMYVZPMC36BPJXMV2'
EVENTBRITE_CLIENT_SECRET = 'KCI5LM3WL3HJNDOD4EA4E3NHJ4P5BQYFMQDUUG46PSGC2YF7QU'

passport.use new EventbriteStrategy(
  clientID: EVENTBRITE_CLIENT_ID
  clientSecret: EVENTBRITE_CLIENT_SECRET
  callbackURL: "#{baseUrl}/eventbrite/auth/callback"
  passReqToCallback: true
  ,
  (req, accessToken, refreshToken, profile, done)->
    require("./models/user").upsert 'eventbrite', accessToken, profile, (err, user)->
      console.log err if err?
      setSession req, accessToken, user
      done null, profile
)

app.get "/eventbrite/login", (req, res) ->
  user = req.user
  return res.send user if user?
  res.send '<a href="/eventbrite/auth">Login with Eventbrite</a>'

app.get "/eventbrite/account", ensureAuthenticated, (req, res) ->
  res.send req.user


app.get "/eventbrite/auth", passport.authenticate("eventbrite",
  state: "SOME STATE"
), (req, res) ->

app.get "/eventbrite/auth/callback", passport.authenticate("eventbrite",
  failureRedirect: "/eventbrite/login"
), (req, res) ->
  res.redirect "/"

app.get "/eventbrite/logout", (req, res) ->
  req.logout()
  req.session.destroy()
  console.log "logging out", req.session
  res.redirect "/"


##############User#################

user = require './models/user'
app.get '/user', ensureAuthenticated, user.list
app.post '/user', ensureAuthenticated, user.create
app.get '/user/:authId', ensureAuthenticated, user.find
app.put '/user', ensureAuthenticated, user.update
app.get '/matches', ensureAuthenticated, user.matches
#app.delete '/user/:name', user.delete

event = require './models/event'
app.get 'attendees/:eventId', event.getAttendees


http = require("http")
http.createServer(app).listen(process.env.PORT||3000)
