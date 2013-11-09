app = angular.module 'hackerApp', ['ui.router']

app.controller 'hackerCtrl', ['$scope', ($scope)->
	ajax = (url, {method, data} , cb)->
		info = 
			url: url
			method: method || 'get'

		if data
			if info.method=='get'
				info.params = data
			else
				info.data = $.param(data)
				info.headers = {'Content-Type': 'application/x-www-form-urlencoded'}

		$http(info).success (o)->
			[status, data] = o
			cb(status, data)

	$scope.reverseMatch= true
	$scope.hackers = [
		{
			id: 1
			name: 'Phil'
			roles: ['backend']
			skillsets:
				backend: ['ruby', 'node']
			idea: "I want to build a medical startup"
			match: 30
		}
		{
			id: 2
			name: 'Eve'
			roles: ['hustler']
			skillsets:
				hustler: ['excel']
			idea: "I want to build a dog food startup"
			match: 50
		}
		{
			id: 3
			name: 'Omar'
			roles: ['mobile']
			skillsets:
				mobile: ['ios', 'android']
			idea: "I want to build a medical startup as well"
			match: 80
		}
		{
			id: 4
			name: 'Jashua'
			roles: ['backend']
			skillsets:
				mobile: ['node', 'ruby on rails']
			idea: "I want to build a linkedin bluetooth app"
			match: 100
		}
	]
]