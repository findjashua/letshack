firebase_url = "https://letshack.firebaseio.com/"

app = angular.module 'hackerApp', ['ui.router', 'firebase']

app.filter 'filterByRole', ->
	(input, rolelist)->
		output = []
		checked = (r.name for r in rolelist when r.checked)
		for i in input 
			if _.intersection(checked, i.roles).length
				output.push i
		output

app.filter 'filterByInterest', ->
	(input, interestlist)->
		output = []
		checked = (i.name for i in interestlist when i.checked)
		for i in input
			if _.intersection(checked, i.interests).length
				output.push i
		output

app.controller 'messageCtrl', ['$scope', 'angularFire', ($scope, angularFire)->
	ref = new Firebase(firebase_url+"messages")
	$scope.messages = []
	angularFire(ref.limit(100), $scope, 'messages')
	$scope.addMessage = (e)->
		return if e.keyCode!=13
		$scope.messages.push {from: 'anonymous', msg: $scope.msg}
		$scope.msg = ''
]

app.controller 'loginCtrl', ['$scope', ($scope)->
]

app.controller 'setProfileCtrl', ['$scope', ($scope)->
]

app.controller 'findHackerCtrl', ['$scope', ($scope)->
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

	$scope.rolelist = [
		{name: 'frontend', checked:true}
		{name:'backend', checked: true} 
		{name:'designer', checked: true}
		{name:'hustler', checked: true}
		{name:'mobile', checked: true}
	]

	$scope.interestlist = [
		{name: 'healthcare', checked: true}
		{name: 'social media', checked: true}
		{name: 'social network', checked: true}
		{name: 'advertising', checked: true}
		{name: 'wearables', checked: true}
		{name: 'google glasses', checked: true}
	]

	$scope.reverseMatch= true

	$scope.setAllInterest = (param)->
		for i in $scope.interestlist
			i.checked = param

	$scope.setAllRole = (param)->
		for r in $scope.rolelist
			r.checked = param

	$scope.hackers = [
		{
			id: 1
			name: 'Phil'
			roles: ['backend']
			skillsets:
				backend: ['ruby', 'node']
			interests: ['healthcare', 'social media']
			looking_for: ['frontend', 'designer']
			idea: "I want to build a medical startup"
			match: 30
		}
		{
			id: 2
			name: 'Eve'
			roles: ['hustler']
			skillsets:
				hustler: ['excel']
			interests: ['wearables']
			looking_for: ['frontend', 'backend', 'designer']
			idea: "I want to build a dog food startup"
			match: 50
		}
		{
			id: 3
			name: 'Omar'
			roles: ['mobile']
			skillsets:
				mobile: ['ios', 'android']
			interests: ['google glasses']
			looking_for: ['backend']
			idea: "I want to build a medical startup as well"
			match: 80
		}
		{
			id: 4
			name: 'Jashua'
			roles: ['backend']
			skillsets:
				mobile: ['node', 'ruby on rails']
			interests: ['advertising']
			looking_for: ['frontend']
			idea: "I want to build a linkedin bluetooth app"
			match: 100
		}
	]
]