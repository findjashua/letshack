mongoose = require 'mongoose'
eventbrite = require '../apis/eventbrite'

url = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/letshack'
db = mongoose.createConnection url

Schema = mongoose.Schema

eventSchema = new Schema
	id : {type : Number}
	title : {type : String}
	start_date : {type : String}
	end_date : {type : String}

userSchema = new Schema
	name : {type : String}
	auth : 
		provider : {type : String, required : true}
		id : {type : String, required : true, unique : true}
		token : {type : String, required : true}
	events : [eventSchema]
	location : {type : String}
	pictureUrl : {type : String}
	roles : [String]
	skills : [String]
	industries : [String]
	ideas : [String]
	seeking_roles : [String]
	seeking_skills : [String]
	pings : 
		unresponded : [Schema.Types.Objectid]
		accepted : [Schema.Types.Objectid]
		rejected : [Schema.Types.Objectid]	
	complete : {type : Boolean}

User = db.model 'User', userSchema

getEvents = (accessToken, callback)->
	eventbrite.getEvents accessToken, (err, events)->
		console.log err if err?
		callback null, events

exports.upsert = (authProvider, accessToken, profile, callback)-> 
	condition =  "auth.id" : "#{profile.id}"
	User.findOne condition, (err, user)->
		if not user?
			user = new User
				auth : 
					provider : authProvider
					id : profile.id
					token : accessToken
				name : profile.displayName
				location : profile._json.location?.name
				pictureUrl : profile._json.pictureUrl
		else
			user.auth.token = accessToken
		getEvents accessToken, (err, events)->
			console.log events
			user.events = events
			user.save (err, data)->
				return console.log err if err?	
				callback null, user

exports.list = (req, res)->
	user = User.find (err, users)->
		return res.send err if err?
		return res.send users

exports.create = (req, res)->
	user = new User(req.body)
	user.save (err, user)->
		return res.send err if err?
		return res.send user

exports.find = (req, res)->
	User.findOne {"auth.id" : "#{req.params.authId}"}, (err, user)->
		return res.send err if err?
		return res.send user

exports.update = (req, res)->
	if not req.user?
		res.redirect "/linkedin/login"
	User.update {"auth.id" : "#{req.session.authId}"}, req.body, (err, user)->
		return res.send err if err?
		req.session.complete = true
		return res.send 200










