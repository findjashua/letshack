ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/login"
express = require("express")
passport = require("passport")
linkedin = require("passport-linkedin-oauth2")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
stylus = require('stylus')

LinkedinStrategy = linkedin.Strategy
LINKEDIN_CLIENT_ID = "75agqd2lrg9ozy"
LINKEDIN_CLIENT_SECRET = "0c1wXQ6vuAfoTN9Z"
passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

passport.use new LinkedinStrategy(
  clientID: LINKEDIN_CLIENT_ID
  clientSecret: LINKEDIN_CLIENT_SECRET
  callbackURL: "http://localhost:3000/linkedin/auth/callback"
  #scope: ["r_basicprofile", "r_emailaddress"]
  passReqToCallback: true
, (req, accessToken, refreshToken, profile, done) ->
  req.session.accessToken = accessToken
  done null, profile
)
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
app.use app.router
app.use stylus.middleware(
	src: __dirname + '/views'
	dest: __dirname + '/public'
)
app.use express.static(__dirname + "/public")

app.get "/", (req, res)->
  res.render('index', { title: 'Express' })

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
  res.redirect "/linkedin/account"

app.get "/linkedin/logout", (req, res) ->
  req.logout()
  res.redirect "/linkedin/login"

http = require("http")
http.createServer(app).listen 3000
