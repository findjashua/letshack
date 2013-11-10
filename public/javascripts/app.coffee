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
			if _.intersection(checked, i.industries).length
				output.push i
		output

app.filter 'filterBySkills', ->
	(input, skillslist)->
		output = []
		checked = (i.name for i in skillslist when i.checked)
		for i in input
			if _.intersection(checked, i.skills).length
				output.push i
		output

app.filter 'space2under', ->
	(text)->
		text.replace(/\s/,'_')

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

app.controller 'findHackerCtrl', ['$scope', '$window','$http', ($scope, $window, $http)->

	$scope.hackers_loaded = false
	$scope.session_data = $window.session_data
	$scope.isComplete = $window.session_data && $window.session_data.complete

	$scope.new_user_idea = ''
	$scope.new_user_profile =
		roles: {}
		industries: {}
		skills: {}
		seeking_roles: {}
		seeking_skills: {}


	$scope.updateOrderType = ->
		$scope.orderType = "-scores.#{$scope.orderToken}"

	$scope.orderToken = 'match_score'
	$scope.updateOrderType()

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
			transformed_user_profile_data[k] = (kk for kk,vv of v when vv)

		transformed_user_profile_data.ideas = [$scope.new_user_idea]
		transformed_user_profile_data.complete = true

		ajax "/user", {method: 'put', data: transformed_user_profile_data}, (data)->
			$scope.session_data.complete = true
			$scope.isComplete = true
			$scope.profile_data = transformed_user_profile_data
			$scope.fetch_user $scope.session_data.authId, (data)->
				$scope.you = data
				$scope.fetchHackers (hackers)->
					$scope.$apply ->
						$scope.initHackers hackers

	$scope.rolelist = [
		{name:'backend', checked: true} 
		{name:'business', checked: true}
		{name:'designer', checked: true}
		{name: 'frontend', checked:true}
		{name:'mobile', checked: true}
	]

	$scope.interestlist = [
		{name: 'advertising', checked: true}
		{name: 'games', checked: true}
		{name: 'healthcare', checked: true}
		{name: 'social media', checked: true}
		{name: 'social network', checked: true}
		{name: 'wearables', checked: true}
		{name: 'google glasses', checked: true}
	]

	$scope.skillslist = [
		{name: 'android', checked: true}
		{name: 'javascript', checked: true}
		{name: 'haskell', checked: true}
		{name: 'ios', checked: true}
		{name: 'nodejs', checked: true}
		{name: 'pitching', checked: true}
		{name: 'python', checked: true}
		{name: 'ruby', checked: true}
		{name: 'ruby on rails', checked: true}
	]

	$scope.reverseMatch= true
	$scope.hackers = []

	$scope.users_data = {}

	$scope.fetch_user = (authId, cb)->
		ajax "/user/#{authId}", {}, (data)->
			$scope.users_data[authId.toString()] = data
			cb(data)

	$scope.setAll = (field, param)->
		for i in $scope[field]
			i.checked = param

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

	$scope.fetchHackers = (hackers)->
		ajax "/matches", {}, (data)->
			{scores, userList} = data
			scores_map = {}
			hackers = []
			for s in scores
				scores_map[s.id.toString()] = s
			for u,i in userList
				if score = scores_map[u.auth.id.toString()]
					u.scores = score
					hackers.push u
			$scope.hackers = hackers
			$scope.hackers_loaded = true

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

	# hackers = [
	# 	{
	# 		id: 1
	# 		name: 'Phil'
	# 		roles: ['backend']
	# 		skills: ['ruby', 'node']
	# 		interests: ['healthcare', 'social media']
	# 		looking_for: ['frontend', 'designer']
	# 		idea: "I want to build a medical startup"
	# 		locationName: "new york, ny"
	# 		match: 30
	# 	}
	# 	{
	# 		id: 2
	# 		name: 'Eve'
	# 		roles: ['business']
	# 		skills: ['pitching']
	# 		interests: ['wearables']
	# 		looking_for: ['frontend', 'backend', 'designer']
	# 		idea: "I want to build a dog food startup"
	# 		match: 50
	# 	}
	# 	{
	# 		id: 3
	# 		name: 'Omar'
	# 		roles: ['mobile']
	# 		skills: ['ios', 'android']
	# 		interests: ['google glasses']
	# 		looking_for: ['backend']
	# 		idea: "I want to build a medical startup as well"
	# 		location:
	# 			lat: 45
	# 			long: -73
	# 		match: 80
	# 	}
	# 	{
	# 		id: 4
	# 		name: 'Jashua'
	# 		roles: ['backend']
	# 		skills: ['node', 'ruby on rails']
	# 		interests: ['advertising']
	# 		looking_for: ['frontend']
	# 		idea: "I want to build a linkedin bluetooth app"
	# 		location:
	# 			lat: 45
	# 			long: -73
	# 		match: 100
	# 	}
	# ]

	$scope.displayChecked = (h)->
		checked = (hh.name for hh in h when hh.checked)
		if checked.length==_.size(h)
			"all selected"
		else if checked.length==0
			"none"
		else
			checked.join(', ')

	window.onGoogleReady = ->
		window.geocoder = new google.maps.Geocoder()
		if $scope.isComplete
			$scope.fetch_user $window.session_data.authId, (data)->
				$scope.you = data
				$scope.fetchHackers (hackers)->
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