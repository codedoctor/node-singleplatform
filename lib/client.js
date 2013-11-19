(function() {
  var client, _,
    _this = this;

  _ = require('underscore');

  /*
  Creates a new client object.
  @param [Object] settings the client settings
  @option settings [String] apiUri the API target URI, defaults to http://api.singleplatform.co
  @option settings [String] clientId the clientId from singleplatform
  @option settings [String] apiKey the apiKey from singleplatform
  @option settings [String] signingKey the signingKey from singleplatform
  @option settings [String] referrer a string that uniquely identifies you against singleplatform, like your company name. This will be sent along in the http referrer header
  */


  module.exports = client = function(settings) {
    var c;
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
    if (!settings.referrer) {
      throw new Error("settings.referrer is a required parameter");
    }
    c = {
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
          if (page == null) {
            page = 0;
          }
          if (count == null) {
            count = 20;
          }
          if (updatedSince == null) {
            updatedSince = null;
          }
          if (!cb) {
            throw new Error("cb is a required parameter");
          }
          return cb(null);
        },
        /*
        Returns location information for the specified location id.
        URI: /locations/LOCATION
        @param [String] locationId The location id
        */

        get: function(locationId, cb) {
          if (!cb) {
            throw new Error("cb is a required parameter");
          }
          return cb(null);
        },
        /*
        Returns menu information for the specified location id.
        URI /locations/LOCATION/menu
        @param [String] locationId The location id
        */

        getMenu: function(locationId, cb) {
          if (!cb) {
            throw new Error("cb is a required parameter");
          }
          return cb(null);
        },
        /*
        Returns short menu information for the specified location id.
        URI /locations/LOCATION/shortmenu
        @param [String] locationId The location id
        */

        getShortMenu: function(location, cb) {
          if (!cb) {
            throw new Error("cb is a required parameter");
          }
          return cb(null);
        }
      }
    };
    return c;
  };

}).call(this);

/*
//@ sourceMappingURL=client.js.map
*/