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
	roles : [String]
	technologies : [String]
	industries : [String]
	ideas : [String]
	location : {type : String}
	pings : 
		unresponded : [Schema.Types.Objectid]
		accepted : [Schema.Types.Objectid]
		rejected : [Schema.Types.Objectid]	
	available : {type : Boolean, default : true}
	completed : {type : Boolean}

User = db.model 'User', schema

exports.upsert = (authProvider, accessToken, profile)-> 
	condition =  "auth.id" : "#{profile.id}"
	User.count condition, (err, data)->
		if data is 0
			user = new User
				auth : 
					provider : authProvider
					id : profile.id
					token : accessToken
				name : profile.displayName
				location : profile._json.location.name
			user.save (err, data)->
				console.log err if err?

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








