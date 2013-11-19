(function() {
  var client, crypto, qs, request, _;

  _ = require('underscore');

  request = require('request');

  qs = require('querystring');

  crypto = require('crypto');

  /*
  Creates a new client object.
  @param [Object] settings the client settings
  @option settings [String] apiUri the API target URI, defaults to http://api.singleplatform.co
  @option settings [String] clientId the clientId from singleplatform
  @option settings [String] apiKey the apiKey from singleplatform
  @option settings [String] signingKey the signingKey from singleplatform
  @option settings [String] referer a string that uniquely identifies you against singleplatform, like your company name. This will be sent along in the http referer header
  */


  module.exports = client = function(settings) {
    var c, _buildUri, _handleRequestResult, _invokeRequest, _normalizeQueryString;
    if (settings == null) {
      settings = {};
    }
    _.defaults(settings, {
      apiUri: "http://api.singleplatform.co"
    });
    if (!settings.clientId) {
      throw new Error("settings.clientId is a required parameter");
    }
    if (!settings.apiKey) {
      throw new Error("settings.apiKey is a required parameter");
    }
    if (!settings.signingKey) {
      throw new Error("settings.signingKey is a required parameter");
    }
    if (!settings.referer) {
      throw new Error("settings.referer is a required parameter");
    }
    _normalizeQueryString = function(query) {
      if (query == null) {
        query = '';
      }
      return query = query.replace(/\s/g, '+');
    };
    _handleRequestResult = function(err, res, bodyBeforeJson, cb) {
      var body, e;
      if (err) {
        err.status = res ? res.statusCode || 500 : 500;
        return cb(err);
      }
      if (res.statusCode === 401 || res.statusCode === 403) {
        return cb(new Error("Access Denied with " + res.statusCode));
      }
      body = null;
      if (bodyBeforeJson && bodyBeforeJson.length > 0) {
        try {
          body = JSON.parse(bodyBeforeJson);
        } catch (_error) {
          e = _error;
          return cb(new Error("Invalid Body Content"), bodyBeforeJson, res.statusCode);
        }
      }
      if (!(res.statusCode >= 200 && res.statusCode < 300)) {
        return cb(new Error(body ? body.message : "Request failed."));
      }
      return cb(null, body, res.statusCode);
    };
    _buildUri = function(path, queryString) {
      var body, hmac, qs1, sig, signingKeyBinary, step1, step2;
      step1 = "" + path + "?" + (qs.stringify(queryString));
      signingKeyBinary = new Buffer(settings.signingKey, 'base64');
      body = new Buffer(step1, 'utf8');
      hmac = crypto.createHmac('sha1', signingKeyBinary);
      hmac.setEncoding('base64');
      hmac.write(body);
      hmac.end();
      sig = hmac.read();
      sig = sig.replace(/\+/g, '-');
      sig = sig.replace(/\//g, '_');
      sig = sig.replace(/\=$/, '');
      qs1 = qs.stringify(queryString);
      if (qs1.length !== 0) {
        qs1 += "&";
      }
      qs1 += "sig=" + sig;
      step2 = "" + settings.apiUri + path + "?" + qs1;
      return step2;
    };
    /*
    Calls the API. 
    @param [String] path the path segment of the query, like /locations/search. Must start with /. No trailing /
    */

    _invokeRequest = function(path, queryString, cb) {
      var headers;
      if (path == null) {
        path = "";
      }
      if (queryString == null) {
        queryString = {};
      }
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Referrer': settings.referer,
        'Referer': settings.referer
      };
      queryString.client = settings.clientId;
      return request({
        uri: _buildUri(path, queryString),
        headers: headers,
        method: "GET"
      }, function(err, res, bodyBeforeJson) {
        return _handleRequestResult(err, res, bodyBeforeJson, cb);
      });
    };
    c = {
      _handleRequestResult: _handleRequestResult,
      _invokeRequest: _invokeRequest,
      _buildUri: _buildUri,
      _normalizeQueryString: _normalizeQueryString,
      locations: {
        /*
        Returns search results 
        URI: /locations/search
        @param [String] q The query string. A free-form query, it searches in the following ways (NOTE: blank queries return nothing):
            by phone number in one of these forms: 10 sequential digits; with dash or period separators (ex: XXX-XXX-XXXX)
            by zip code in one of these forms: 5 digit zip, 9 digit zip with dash (ex. 10001-4356)
            by name of location
        @param [Number] page The page number. A zero-based value. The default value is 0 for the first page.
        @param [Number] count The number of results per page. The default value is 20, and the maximum value is 1000.
        @param [String] updatedSince For refresher queries. Format YYYY-MM-DD or  YYYY-MM-DDTHH:MM:SS NOTE: We do the URL encoding
        */

        search: function(q, page, count, updatedSince, cb) {
          var queryString;
          if (page == null) {
            page = 0;
          }
          if (count == null) {
            count = 20;
          }
          if (updatedSince == null) {
            updatedSince = null;
          }
          if (!(cb && typeof cb === 'function')) {
            throw new Error("cb is a required parameter");
          }
          q = _normalizeQueryString(q);
          queryString = {
            q: q,
            page: page,
            count: count
          };
          if (updatedSince) {
            queryString.updatedSince = updatedSince;
          }
          return _invokeRequest("/locations/search", queryString, cb);
        },
        /*
        Returns location information for the specified location id.
        URI: /locations/LOCATION
        @param [String] locationId The location id
        */

        get: function(locationId, cb) {
          if (!(cb && typeof cb === 'function')) {
            throw new Error("cb is a required parameter");
          }
          return _invokeRequest("/locations/" + locationId, {}, cb);
        },
        /*
        Returns menu information for the specified location id.
        URI /locations/LOCATION/menu
        @param [String] locationId The location id
        */

        getMenu: function(locationId, cb) {
          if (!(cb && typeof cb === 'function')) {
            throw new Error("cb is a required parameter");
          }
          return _invokeRequest("/locations/" + locationId + "/menu", {}, cb);
        },
        /*
        Returns short menu information for the specified location id.
        URI /locations/LOCATION/shortmenu
        @param [String] locationId The location id
        */

        getShortMenu: function(locationId, cb) {
          if (!(cb && typeof cb === 'function')) {
            throw new Error("cb is a required parameter");
          }
          return _invokeRequest("/locations/" + locationId + "/shortmenu", {}, cb);
        }
      }
    };
    return c;
  };

}).call(this);

/*
//@ sourceMappingURL=client.js.map
*/