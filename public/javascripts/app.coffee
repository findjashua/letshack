firebase_url = "https://letshack.firebaseio.com/"

app = angular.module 'hackerApp', ['ui.router','ui.event', 'ui.map','firebase', 'ngAnimate']

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


app.controller 'messageCtrl', ['$scope', 'angularFire', '$timeout','$http', ($scope, angularFire, $timeout, $http)->
	ref = new Firebase(firebase_url+"messages")
	$scope.messages = []
	angularFire(ref.limit(100), $scope, 'messages')
	
	$scope.addMessage = (e)->
		return if e.keyCode!=13
		$scope.messages.push {from: 'anonymous', msg: $scope.msg}
		$scope.msg = ''
		$timeout ->
			$scope.scrollBottom()
		, 250
	
	$scope.scrollBottom = ->
		scrollDiv = document.getElementById 'messages'
		scrollDiv.scrollTop+=scrollDiv.scrollHeight

	$timeout ->
		$scope.scrollBottom()
	, 1000
]

app.controller 'loginCtrl', ['$scope', ($scope)->
]


app.controller 'findHackerCtrl', ['$scope', '$window','$http', ($scope, $window, $http)->

	$scope.session_data = $window.session_data
	$scope.isComplete = $window.session_data && $window.session_data.complete

	$scope.new_user_profile =
		roles: {}
		industries: {}
		skills: {}
		seeking_roles: {}
		seeking_skills: {}


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

		$http(info).success (data)->
			cb(data)

	$scope.submit_profile = ->
		transformed_user_profile_data = {}
		for k,v of $scope.new_user_profile
			transformed_user_profile_data[k] = (kk for kk,vv of v)
		
		ajax "/user/profile", {method: 'post', data: transformed_user_profile_data}, (data)->
			console.log data


	$scope.rolelist = [
		{name: 'frontend', checked:true}
		{name:'backend', checked: true} 
		{name:'designer', checked: true}
		{name:'business', checked: true}
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

	$scope.skillslist = [
		{name: 'javascript', checked: true}
		{name: 'ruby', checked: true}
		{name: 'python', checked: true}
		{name: 'ios', checked: true}
		{name: 'android', checked: true}
		{name: 'ruby on rails', checked: true}
	]

	$scope.reverseMatch= true
	$scope.hackers = []

	$scope.setAllInterest = (param)->
		for i in $scope.interestlist
			i.checked = param

	$scope.setAllRole = (param)->
		for r in $scope.rolelist
			r.checked = param

	$scope.initLocation = (h)->
		ll = new google.maps.LatLng(h.location.lat, h.location.long)
		h.mapOptions = 
			center: ll
			zoom: 10
			mapTypeId: google.maps.MapTypeId.ROADMAP
			disableDefaultUI: true
		
		h.onMapIdle = ->
			$scope.$apply ->
				h.marker = new google.maps.Marker
					map: h.googlemap,
					position: ll

	$scope.initHackers = (hackers)->
		$scope.hackers = hackers
		for h in $scope.hackers
			do (h)->
				if h.location
					$scope.initLocation(h)
				else
					if h.locationName
						fetch_address h.locationName, (latitude, longitude)->
							if latitude && longitude
								h.location = 
									lat: latitude
									long: longitude
								$scope.initLocation(h)

	hackers = [
		{
			id: 1
			name: 'Phil'
			roles: ['backend']
			skillsets:
				backend: ['ruby', 'node']
			interests: ['healthcare', 'social media']
			looking_for: ['frontend', 'designer']
			idea: "I want to build a medical startup"
			locationName: "new york, ny"
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
			layout: ['google glasses']
			looking_for: ['backend']
			idea: "I want to build a medical startup as well"
			location:
				lat: 45
				long: -73
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
			location:
				lat: 45
				long: -73
			match: 100
		}
	]
	window.onGoogleReady = ->
		window.geocoder = new google.maps.Geocoder()
		$scope.$apply ->
			$scope.initHackers hackers

]


window.fetch_address = (address, cb)->
	geocoder.geocode { 'address': address}, (results, status)->
		if (status == google.maps.GeocoderStatus.OK)
			latitude = results[0].geometry.location.lat();
			longitude = results[0].geometry.location.lng();
			cb(latitude, longitude)
		else
			cb(null)