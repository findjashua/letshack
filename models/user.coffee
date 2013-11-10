mongoose = require 'mongoose'
eventbrite = require '../apis/eventbrite'
Event = require './event'
_ = require 'underscore'

url = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/letshack'
db = mongoose.createConnection url

Schema = mongoose.Schema

eventSchema = new Schema
	id : {type : String}
	title : {type : String}
	start_date : {type : String}
	end_date : {type : String}

scoreSchema = new Schema
	id : {type : String}
	they_want_you : {type : Number}
	you_want_them : {type : Number}
	match_score : {type : Number}

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
	scores : [scoreSchema]

	pings : 
		unresponded : [Schema.Types.Objectid]
		accepted : [Schema.Types.Objectid]
		rejected : [Schema.Types.Objectid]	
	complete : {type : Boolean}

User = db.model 'User', userSchema

calcIntersectOverUnion = (arr1, arr2)->
	(_.intersection arr1, arr2).length*100/(_.union arr1, arr2).length

avg = (numbers...)->
	sum = numbers.reduce (s,e)-> 
		s+=e;s
	, 0
	sum/numbers.length

computeScores = (currUser)->
	User.find (err, users)->
		console.log err if err?
		for user in users
			continue if user?.auth.id is currUser?.auth.id
			continue unless user.complete && currUser.complete
				
			roles = calcIntersectOverUnion(currUser.roles, user.seeking_roles)
			skills = calcIntersectOverUnion(currUser.skills, user.seeking_skills)

			roles_inverse = calcIntersectOverUnion(currUser.seeking_roles, user.roles)
			skills_inverse = calcIntersectOverUnion(currUser.seeking_skills, user.skills)
			
			they_want_you = avg roles, skills
			you_want_them = avg roles_inverse, skills_inverse
			match_score = avg they_want_you, you_want_them
			currUser.scores.push 
				id : user.auth.id
				'they_want_you' : they_want_you
				'you_want_them' : you_want_them
				'match_score' : match_score
			
			user.scores.push
				id : currUser.auth.id
				'you_want_them' : you_want_them
				'they_want_you' : they_want_you
				'match_score' : match_score
			user.save()
		currUser.save()

getEvents = (accessToken, attendeeId, callback)->
	eventbrite.getEvents accessToken, (err, events)->
		console.log err if err?
		for event in events
			Event.createOrUpdate event.id, attendeeId
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
		
			getEvents accessToken, profile.id, (err, events)->
				user.events = events
				user.scores = []
				user.save (err, data)->
					return console.log err if err?	
					callback null, user				
		else
			user.auth.token = accessToken
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
	User.update {"auth.id" : "#{req.session.authId}"}, req.body, (err, num)->
		return res.send err if err?
		req.session.complete = true
		User.findOne {"auth.id" : "#{req.session.authId}"}, (err, user)->
			console.log err if err?
			computeScores user
			return res.send 200

exports.matches = (req, res)->
	User.find (err, users)->
		return res.send err if err?
		User.findOne {"auth.id" : "#{req.session.authId}"}, (err, user)->
			return res.send err if err?
			payload = 
				scores : user.scores
				userList : users
			return res.send payload












