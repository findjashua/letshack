// Generated by CoffeeScript 1.6.2
(function() {
  var app, firebase_url;

  firebase_url = "https://letshack.firebaseio.com/";

  app = angular.module('hackerApp', ['ui.router', 'ui.event', 'ui.map', 'firebase', 'ngAnimate']);

  app.filter('filterByRole', function() {
    return function(input, rolelist) {
      var checked, i, output, r, _i, _len;

      output = [];
      checked = (function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = rolelist.length; _i < _len; _i++) {
          r = rolelist[_i];
          if (r.checked) {
            _results.push(r.name);
          }
        }
        return _results;
      })();
      for (_i = 0, _len = input.length; _i < _len; _i++) {
        i = input[_i];
        if (_.intersection(checked, i.roles).length) {
          output.push(i);
        }
      }
      return output;
    };
  });

  app.filter('filterByInterest', function() {
    return function(input, interestlist) {
      var checked, i, output, _i, _len;

      output = [];
      checked = (function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = interestlist.length; _i < _len; _i++) {
          i = interestlist[_i];
          if (i.checked) {
            _results.push(i.name);
          }
        }
        return _results;
      })();
      for (_i = 0, _len = input.length; _i < _len; _i++) {
        i = input[_i];
        if (_.intersection(checked, i.interests).length) {
          output.push(i);
        }
      }
      return output;
    };
  });

  app.controller('messageCtrl', [
    '$scope', 'angularFire', '$timeout', '$http', function($scope, angularFire, $timeout, $http) {
      var ref;

      ref = new Firebase(firebase_url + "messages");
      $scope.messages = [];
      angularFire(ref.limit(100), $scope, 'messages');
      $scope.addMessage = function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        $scope.messages.push({
          from: 'anonymous',
          msg: $scope.msg
        });
        $scope.msg = '';
        return $timeout(function() {
          return $scope.scrollBottom();
        }, 250);
      };
      $scope.scrollBottom = function() {
        var scrollDiv;

        scrollDiv = document.getElementById('messages');
        return scrollDiv.scrollTop += scrollDiv.scrollHeight;
      };
      return $timeout(function() {
        return $scope.scrollBottom();
      }, 1000);
    }
  ]);

  app.controller('loginCtrl', ['$scope', function($scope) {}]);

  app.controller('findHackerCtrl', [
    '$scope', '$window', '$http', function($scope, $window, $http) {
      var ajax, hackers;

      $scope.session_data = $window.session_data;
      $scope.isComplete = $window.session_data && $window.session_data.complete;
      $scope.new_user_profile = {
        roles: {},
        industries: {},
        skills: {},
        seeking_roles: {},
        seeking_skills: {}
      };
      ajax = function(url, _arg, cb) {
        var data, info, method;

        method = _arg.method, data = _arg.data;
        info = {
          url: url,
          method: method || 'get'
        };
        if (data) {
          if (info.method === 'get') {
            info.params = data;
          } else {
            info.data = $.param(data);
            info.headers = {
              'Content-Type': 'application/x-www-form-urlencoded'
            };
          }
        }
        return $http(info).success(function(data) {
          return cb(data);
        });
      };
      $scope.submit_profile = function() {
        var k, kk, transformed_user_profile_data, v, vv, _ref;

        transformed_user_profile_data = {};
        _ref = $scope.new_user_profile;
        for (k in _ref) {
          v = _ref[k];
          transformed_user_profile_data[k] = (function() {
            var _results;

            _results = [];
            for (kk in v) {
              vv = v[kk];
              _results.push(kk);
            }
            return _results;
          })();
        }
        return ajax("/user", {
          method: 'put',
          data: transformed_user_profile_data
        }, function(data) {
          return console.log(data);
        });
      };
      $scope.rolelist = [
        {
          name: 'frontend',
          checked: true
        }, {
          name: 'backend',
          checked: true
        }, {
          name: 'designer',
          checked: true
        }, {
          name: 'business',
          checked: true
        }, {
          name: 'mobile',
          checked: true
        }
      ];
      $scope.interestlist = [
        {
          name: 'healthcare',
          checked: true
        }, {
          name: 'social media',
          checked: true
        }, {
          name: 'social network',
          checked: true
        }, {
          name: 'advertising',
          checked: true
        }, {
          name: 'wearables',
          checked: true
        }, {
          name: 'google glasses',
          checked: true
        }
      ];
      $scope.skillslist = [
        {
          name: 'javascript',
          checked: true
        }, {
          name: 'ruby',
          checked: true
        }, {
          name: 'python',
          checked: true
        }, {
          name: 'ios',
          checked: true
        }, {
          name: 'android',
          checked: true
        }, {
          name: 'ruby on rails',
          checked: true
        }
      ];
      $scope.reverseMatch = true;
      $scope.hackers = [];
      $scope.setAllInterest = function(param) {
        var i, _i, _len, _ref, _results;

        _ref = $scope.interestlist;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.checked = param);
        }
        return _results;
      };
      $scope.setAllRole = function(param) {
        var r, _i, _len, _ref, _results;

        _ref = $scope.rolelist;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          _results.push(r.checked = param);
        }
        return _results;
      };
      $scope.initLocation = function(h) {
        var ll;

        ll = new google.maps.LatLng(h.location.lat, h.location.long);
        h.mapOptions = {
          center: ll,
          zoom: 10,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          disableDefaultUI: true
        };
        return h.onMapIdle = function() {
          return $scope.$apply(function() {
            return h.marker = new google.maps.Marker({
              map: h.googlemap,
              position: ll
            });
          });
        };
      };
      $scope.initHackers = function(hackers) {
        var h, _i, _len, _ref, _results;

        $scope.hackers = hackers;
        _ref = $scope.hackers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          h = _ref[_i];
          _results.push((function(h) {
            if (h.location) {
              return $scope.initLocation(h);
            } else {
              if (h.locationName) {
                return fetch_address(h.locationName, function(latitude, longitude) {
                  if (latitude && longitude) {
                    h.location = {
                      lat: latitude,
                      long: longitude
                    };
                    return $scope.initLocation(h);
                  }
                });
              }
            }
          })(h));
        }
        return _results;
      };
      hackers = [
        {
          id: 1,
          name: 'Phil',
          roles: ['backend'],
          skillsets: {
            backend: ['ruby', 'node']
          },
          interests: ['healthcare', 'social media'],
          looking_for: ['frontend', 'designer'],
          idea: "I want to build a medical startup",
          locationName: "new york, ny",
          match: 30
        }, {
          id: 2,
          name: 'Eve',
          roles: ['hustler'],
          skillsets: {
            hustler: ['excel']
          },
          interests: ['wearables'],
          looking_for: ['frontend', 'backend', 'designer'],
          idea: "I want to build a dog food startup",
          match: 50
        }, {
          id: 3,
          name: 'Omar',
          roles: ['mobile'],
          skillsets: {
            mobile: ['ios', 'android']
          },
          layout: ['google glasses'],
          looking_for: ['backend'],
          idea: "I want to build a medical startup as well",
          location: {
            lat: 45,
            long: -73
          },
          match: 80
        }, {
          id: 4,
          name: 'Jashua',
          roles: ['backend'],
          skillsets: {
            mobile: ['node', 'ruby on rails']
          },
          interests: ['advertising'],
          looking_for: ['frontend'],
          idea: "I want to build a linkedin bluetooth app",
          location: {
            lat: 45,
            long: -73
          },
          match: 100
        }
      ];
      return window.onGoogleReady = function() {
        window.geocoder = new google.maps.Geocoder();
        return $scope.$apply(function() {
          return $scope.initHackers(hackers);
        });
      };
    }
  ]);

  window.fetch_address = function(address, cb) {
    return geocoder.geocode({
      'address': address
    }, function(results, status) {
      var latitude, longitude;

      if (status === google.maps.GeocoderStatus.OK) {
        latitude = results[0].geometry.location.lat();
        longitude = results[0].geometry.location.lng();
        return cb(latitude, longitude);
      } else {
        return cb(null);
      }
    });
  };

}).call(this);
