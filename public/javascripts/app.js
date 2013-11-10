// Generated by CoffeeScript 1.6.2
(function() {
  var app, firebase_url;

  firebase_url = "https://letshack.firebaseio.com/";

  app = angular.module('hackerApp', ['ui.router', 'ui.event', 'ui.map', 'firebase']);

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
    '$scope', 'angularFire', '$timeout', function($scope, angularFire, $timeout) {
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

  app.controller('setProfileCtrl', ['$scope', function($scope) {}]);

  app.controller('findHackerCtrl', [
    '$scope', function($scope) {
      var ajax, hackers;

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
        return $http(info).success(function(o) {
          var status;

          status = o[0], data = o[1];
          return cb(status, data);
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
          name: 'hustler',
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
      $scope.initHackers = function(hackers) {
        var h, _i, _len, _ref, _results;

        $scope.hackers = hackers;
        _ref = $scope.hackers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          h = _ref[_i];
          _results.push((function(h) {
            var ll;

            if (h.location) {
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
          interests: ['google glasses'],
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
        return $scope.$apply(function() {
          return $scope.initHackers(hackers);
        });
      };
    }
  ]);

}).call(this);
