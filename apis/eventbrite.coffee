request = require 'request'
BASE_URL = 'https://www.eventbrite.com/json'
APP_KEY = 'RWMYVZPMC36BPJXMV2'
USER_KEY = '131440656219123672419'

exports.getEvents = (accessToken, callback)->
	url = "#{BASE_URL}/user_list_tickets?app_key=#{APP_KEY}&user_key=#{USER_KEY}&access_token=#{accessToken}"
	request.get url, (err, resp, body)->
		return callback err, null if err?
		obj = JSON.parse body
		data = []
		orders = obj.user_tickets[1].orders
		for order in orders
			event = order.order.event
			console.log (k for k,v of event)
			data.push 
				id : event.id
				title : event.title
				start_date : new Date event.start_date
				end_date : new Date event.end_date
			console.log data
		callback null, data


