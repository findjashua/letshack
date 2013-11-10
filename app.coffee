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
app.use express.session(
  secret: "keyboard cat"
)
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


app.get "/", (req, res)->
  res.render('index', { title: 'Express'})

###############LinkedIn#################

linkedin = require("passport-linkedin-oauth2")
LinkedinStrategy = linkedin.Strategy
LINKEDIN_CLIENT_ID = "75agqd2lrg9ozy"
LINKEDIN_CLIENT_SECRET = "0c1wXQ6vuAfoTN9Z"

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

setSession = (req, accessToken, data)->
  req.session.accessToken = accessToken
  req.session.uid = data._id.str
  req.session.authId = data.auth.id
  req.session.name = data.name
  req.session.pictureUrl = data.pictureUrl
  req.session.complete = data.complete?

passport.use new LinkedinStrategy(
  clientID: LINKEDIN_CLIENT_ID
  clientSecret: LINKEDIN_CLIENT_SECRET
  callbackURL: "http://localhost:3000/linkedin/auth/callback"
  passReqToCallback: true
, (req, accessToken, refreshToken, profile, done) ->
    require("./models/user").upsert 'linkedin', accessToken, profile, (err, data)->
      setSession req, accessToken, data
      done null, profile
)

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/linkedin/login"

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


##############User#################

user = require './models/user'
app.get '/user', user.list
app.post '/user', user.create
app.get '/user/:name', user.find
app.put '/user', user.update
###
app.delete '/user/:name', user.delete
###


http = require("http")
http.createServer(app).listen 3000
