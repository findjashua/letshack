mongoose = require 'mongoose'
eventbrite = require '../apis/eventbrite'

url = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/letshack'
db = mongoose.createConnection url

Schema = mongoose.Schema

eventSchema = new Schema
	eventId : {type : Number}
	attendeeIds : [String]

Event = db.model 'Event', eventSchema

exports.createOrUpdate = (eventId, attendeeId)->
	Event.count {"eventId" : "#{eventId}"}, (err, num)->
		if num > 0
			event.attendeeIds.push attendeeId
		else 
			event = new Event
				'eventId' : eventId
				'attendeeIds' : [attendeeId] 
		event.save()
