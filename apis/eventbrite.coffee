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
			data.push order.order.event.id
		callback null, data


