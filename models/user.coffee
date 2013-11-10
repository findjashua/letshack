mongoose = require 'mongoose'

url = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/letshack'
db = mongoose.createConnection url

Schema = mongoose.Schema

schema = new Schema
	name : {type : String}
	auth : 
		provider : {type : String, required : true}
		id : {type : String, required : true, unique : true}
		token : {type : String, required : true}
	location : {type : String}
	pictureUrl : {type : String}
	roles : [String]
	technologies : [String]
	industries : [String]
	ideas : [String]
	seekingRoles : [String]
	seekingSkills : [String]
	pings : 
		unresponded : [Schema.Types.Objectid]
		accepted : [Schema.Types.Objectid]
		rejected : [Schema.Types.Objectid]	
	completed : {type : Boolean}

User = db.model 'User', schema

setSession = (req, user)->

exports.upsert = (authProvider, accessToken, profile, callback)-> 
	condition =  "auth.id" : "#{profile.id}"
	User.findOne condition, (err, data)->
		if not data?
			user = new User
				auth : 
					provider : authProvider
					id : profile.id
					token : accessToken
				name : profile.displayName
				location : profile._json.location.name
				pictureUrl : profile._json.pictureUrl
			user.save (err, data)->
				console.log err if err?
				callback null, data
		else
			callback null, data

exports.list = (req, res)->
	user = User.find (err, data)->
		return res.send err if err?
		return res.send data

exports.create = (req, res)->
	user = new User(req.body)
	user.save (err, data)->
		return res.send err if err?
		return res.send data

exports.find = (req, res)->
	condition = req.query
	User.find condition, (err, data)->
		return res.send err if err?
		return res.send data








