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
        if (_.intersection(checked, i.industries).length) {
          output.push(i);
        }
      }
      return output;
    };
  });

  app.filter('filterBySkills', function() {
    return function(input, skillslist) {
      var checked, i, output, _i, _len;

      output = [];
      checked = (function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = skillslist.length; _i < _len; _i++) {
          i = skillslist[_i];
          if (i.checked) {
            _results.push(i.name);
          }
        }
        return _results;
      })();
      for (_i = 0, _len = input.length; _i < _len; _i++) {
        i = input[_i];
        if (_.intersection(checked, i.skills).length) {
          output.push(i);
        }
      }
      return output;
    };
  });

  app.filter('space2under', function() {
    return function(text) {
      return text.replace(/\s/, '_');
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

  app.controller('findHackerCtrl', [
    '$scope', '$window', '$http', function($scope, $window, $http) {
      var ajax;

      $scope.hackers_loaded = false;
      $scope.session_data = $window.session_data;
      $scope.isComplete = $window.session_data && $window.session_data.complete;
      $scope.new_user_idea = '';
      $scope.new_user_profile = {
        roles: {},
        industries: {},
        skills: {},
        seeking_roles: {},
        seeking_skills: {}
      };
      $scope.updateOrderType = function() {
        return $scope.orderType = "-scores." + $scope.orderToken;
      };
      $scope.orderToken = 'match_score';
      $scope.updateOrderType();
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
              if (vv) {
                _results.push(kk);
              }
            }
            return _results;
          })();
        }
        transformed_user_profile_data.ideas = [$scope.new_user_idea];
        transformed_user_profile_data.complete = true;
        return ajax("/user", {
          method: 'put',
          data: transformed_user_profile_data
        }, function(data) {
          $scope.session_data.complete = true;
          $scope.isComplete = true;
          $scope.profile_data = transformed_user_profile_data;
          return $scope.fetch_user($scope.session_data.authId, function(data) {
            $scope.you = data;
            return $scope.fetchHackers(function(hackers) {
              return $scope.$apply(function() {
                return $scope.initHackers(hackers);
              });
            });
          });
        });
      };
      $scope.rolelist = [
        {
          name: 'backend',
          checked: true
        }, {
          name: 'business',
          checked: true
        }, {
          name: 'designer',
          checked: true
        }, {
          name: 'frontend',
          checked: true
        }, {
          name: 'mobile',
          checked: true
        }
      ];
      $scope.interestlist = [
        {
          name: 'advertising',
          checked: true
        }, {
          name: 'games',
          checked: true
        }, {
          name: 'healthcare',
          checked: true
        }, {
          name: 'social media',
          checked: true
        }, {
          name: 'social network',
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
          name: 'android',
          checked: true
        }, {
          name: 'javascript',
          checked: true
        }, {
          name: 'haskell',
          checked: true
        }, {
          name: 'ios',
          checked: true
        }, {
          name: 'nodejs',
          checked: true
        }, {
          name: 'pitching',
          checked: true
        }, {
          name: 'python',
          checked: true
        }, {
          name: 'ruby',
          checked: true
        }, {
          name: 'ruby on rails',
          checked: true
        }
      ];
      $scope.reverseMatch = true;
      $scope.hackers = [];
      $scope.users_data = {};
      $scope.fetch_user = function(authId, cb) {
        return ajax("/user/" + authId, {}, function(data) {
          $scope.users_data[authId.toString()] = data;
          return cb(data);
        });
      };
      $scope.setAll = function(field, param) {
        var i, _i, _len, _ref, _results;

        _ref = $scope[field];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.checked = param);
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
      $scope.fetchHackers = function(hackers) {
        return ajax("/matches", {}, function(data) {
          var i, s, score, scores, scores_map, u, userList, _i, _j, _len, _len1;

          scores = data.scores, userList = data.userList;
          scores_map = {};
          hackers = [];
          for (_i = 0, _len = scores.length; _i < _len; _i++) {
            s = scores[_i];
            scores_map[s.id.toString()] = s;
          }
          for (i = _j = 0, _len1 = userList.length; _j < _len1; i = ++_j) {
            u = userList[i];
            if (score = scores_map[u.auth.id.toString()]) {
              u.scores = score;
              hackers.push(u);
            }
          }
          $scope.hackers = hackers;
          return $scope.hackers_loaded = true;
        });
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
      $scope.displayChecked = function(h) {
        var checked, hh;

        checked = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = h.length; _i < _len; _i++) {
            hh = h[_i];
            if (hh.checked) {
              _results.push(hh.name);
            }
          }
          return _results;
        })();
        if (checked.length === _.size(h)) {
          return "all selected";
        } else if (checked.length === 0) {
          return "none";
        } else {
          return checked.join(', ');
        }
      };
      return window.onGoogleReady = function() {
        window.geocoder = new google.maps.Geocoder();
        if ($scope.isComplete) {
          return $scope.fetch_user($window.session_data.authId, function(data) {
            $scope.you = data;
            return $scope.fetchHackers(function(hackers) {
              return $scope.$apply(function() {
                return $scope.initHackers(hackers);
              });
            });
          });
        }
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
