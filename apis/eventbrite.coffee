request = require 'request'
BASE_URL = 'https://www.eventbrite.com/json'
APP_KEY = 'RWMYVZPMC36BPJXMV2'
USER_KEY = '131440656219123672419'
#https://www.eventbrite.com/json/user_list_tickets?app_key=RWMYVZPMC36BPJXMV2&user_key=131440656219123672419&access_token=
exports.getEvents = (accessToken, callback)->
	url = "#{BASE_URL}/user_list_tickets?app_key=#{APP_KEY}&user_key=#{USER_KEY}&access_token=#{accessToken}"
	request.get url, (err, resp, body)->
		return callback err, null if err?
		obj = JSON.parse body
		data = []
		orders = obj.user_tickets[1].orders
		for order in orders
			event = order.order.event
			data.push 
				id : event.id
				title : event.title
				start_date : event.start_date
				end_date : event.end_date
		callback null, data


