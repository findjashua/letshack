mongoose = require 'mongoose'
eventbrite = require '../apis/eventbrite'
user = require './user'

url = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/letshack'
db = mongoose.createConnection url

Schema = mongoose.Schema

eventSchema = new Schema
	eventId : {type : Number}
	attendeeIds : [String]

Event = db.model 'Event', eventSchema

exports.createOrUpdate = (eventId, attendeeId)->
	Event.findOne {"eventId" : "#{eventId}"}, (err, event)->
		if event?.attendeeIds?
			event.attendeeIds.push attendeeId
		else 
			event = new Event
				'eventId' : eventId
				'attendeeIds' : [attendeeId] 
		event.save()

exports.getAttendees = (req, res)->
	Event.findOne {"eventId" : "#{req.params.eventId}"}, (err, event)->
		return res.send err if err?
		attendees = []
		for attendeeId in event.attendeeIds
			user.find {"auth.id" : "#{attendeeId}"}, (err, user)->
				if not err?
					attendees.push user


