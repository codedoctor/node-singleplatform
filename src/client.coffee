_ = require 'underscore'
request = require 'request'
qs = require 'querystring'
crypto = require 'crypto'

###
Creates a new client object.
@param [Object] settings the client settings
@option settings [String] apiUri the API target URI, defaults to http://api.singleplatform.co
@option settings [String] clientId the clientId from singleplatform
@option settings [String] apiKey the apiKey from singleplatform
@option settings [String] signingKey the signingKey from singleplatform
@option settings [String] referer a string that uniquely identifies you against singleplatform, like your company name. This will be sent along in the http referer header
###
module.exports = client = (settings = {}) ->
  _.defaults settings, 
      apiUri : "http://api.singleplatform.co"
      matchingUri: "http://matching-api.singleplatform.com"

  throw new Error "settings.clientId is a required parameter" unless settings.clientId
  throw new Error "settings.apiKey is a required parameter" unless settings.apiKey
  throw new Error "settings.signingKey is a required parameter" unless settings.signingKey
  throw new Error "settings.referer is a required parameter" unless settings.referer

  ###
  Search queries need special handling.
  @TODO Look into this in more detail.
  ###
  _normalizeQueryString = (query = '') ->
    query = query.replace /\s/g, '+'

  ###
  Processes the request as returned from the server. Basically, figure out if
  we have a valid JSON result or not.
  ###
  _handleRequestResult = (err, res, bodyBeforeJson,cb) ->
    if err
       err.status = if res then res.statusCode || 500 else 500
       return cb err

    return cb new Error "Access Denied with #{res.statusCode}" if res.statusCode is 401 or res.statusCode is 403

    body = null

    if bodyBeforeJson and bodyBeforeJson.length > 0
      try
        body = JSON.parse(bodyBeforeJson)
      catch e
        return cb( new Error("Invalid Body Content"), bodyBeforeJson, res.statusCode)

    return cb(new Error(if body then body.message else "Request failed.")) unless res.statusCode >= 200 && res.statusCode < 300
    cb null, body, res.statusCode

  ###
  Build a signed URI from the path and the querystring object.
  @param [String] path the path part of the URI, starting with a slash and not ending with one, e.g. /location/search
  @param [Object] queryString the queryString object which will be added to the URI.
  ###
  _buildUri = (path,queryString = {}) ->
    step1 = "#{path}?#{qs.stringify(queryString)}"
    #console.log "Step1: #{step1}"
    
    signingKeyBinary = new Buffer(settings.signingKey, 'base64')
    body = new Buffer(step1, 'utf8')

    hmac = crypto.createHmac('sha1',signingKeyBinary)
    hmac.setEncoding 'base64'
    hmac.write body
    hmac.end()
    sig = hmac.read()
    sig = sig.replace /\+/g, '-' # Format this nicely
    sig = sig.replace /\//g, '_'
    sig = sig.replace /\=$/, '' # Trailing=
    
    qs1 = qs.stringify(queryString)
    qs1 += "&" unless qs1.length is 0
    qs1 += "sig=#{sig}"

    step2 = "#{settings.apiUri}#{path}?#{qs1}"
    #console.log "Step2: #{step2}"
    step2

  ###
  Calls the API. 
  @param [String] path the path segment of the query, like /locations/search. Must start with /. No trailing /
  @param [Object] queryString the queryString object which will be added to the URI.
  @param [Function] cb the callback. 
  @param cb [Error] err an error, or null
  @param cb [Object] body an object containing the parsed result, if no errors
  @param cb [String] statusCode the status code returned from the request operation
  ###
  _invokeRequest = (path = "",queryString = {},cb) ->
    headers =
      'Content-Type': 'application/json'
      'Accept' : 'application/json'
      'Referrer' : settings.referer
      'Referer' : settings.referer

    queryString.client = settings.clientId

    request
        uri: _buildUri(path,queryString)
        headers: headers
        method: "GET"
       , (err, res, bodyBeforeJson) -> _handleRequestResult err, res, bodyBeforeJson,cb

  ###
  Build a signed URI from the path and the querystring object.
  @param [String] path the path part of the URI, starting with a slash and not ending with one, e.g. /location/search
  @param [Object] queryString the queryString object which will be added to the URI.
  ###
  _buildMatchingUri = (path,queryString = {}) ->
    "#{settings.matchingUri}#{path}?#{qs.stringify(queryString)}"
    
  _invokeMatchingRequest = (path = "",body = {},cb) ->
    headers =
      'Content-Type': 'application/json'
      'Accept' : 'application/json'
      'Referrer' : settings.referer
      'Referer' : settings.referer

    queryString =
      client : settings.clientId

    request
        uri: _buildMatchingUri(path,queryString)
        headers: headers
        body: JSON.stringify(body)
        method: "POST"
       , (err, res, bodyBeforeJson) -> _handleRequestResult err, res, bodyBeforeJson,cb


  c = 
    _handleRequestResult : _handleRequestResult # for testing
    _invokeRequest : _invokeRequest # for testing
    _buildUri : _buildUri # for testing
    _normalizeQueryString : _normalizeQueryString
    _invokeMatchingRequest : _invokeMatchingRequest
    _buildMatchingUri : _buildMatchingUri

    locationMatch: (matchData = {},cb) ->
        throw new Error "cb is a required parameter" unless cb and typeof cb is 'function'
        _invokeMatchingRequest "/location-match",matchData,cb

    locations:
      ###
      Returns search results 
      URI: /locations/search
      @param [String] q The query string. A free-form query, it searches in the following ways (NOTE: blank queries return nothing):
          by phone number in one of these forms: 10 sequential digits; with dash or period separators (ex: XXX-XXX-XXXX)
          by zip code in one of these forms: 5 digit zip, 9 digit zip with dash (ex. 10001-4356)
          by name of location
      @param [Number] page The page number. A zero-based value. The default value is 0 for the first page.
      @param [Number] count The number of results per page. The default value is 20, and the maximum value is 1000.
      @param [String] updatedSince For refresher queries. Format YYYY-MM-DD or  YYYY-MM-DDTHH:MM:SS NOTE: We do the URL encoding
      ###
      search: (q,page = 0,count = 20,updatedSince = null,cb) ->
        throw new Error "cb is a required parameter" unless cb and typeof cb is 'function'

        q = _normalizeQueryString(q)

        queryString = 
          q : q
          page : page
          count : count
        queryString.updatedSince = updatedSince if updatedSince

        _invokeRequest "/locations/search",queryString,cb

      ###
      Returns location information for the specified location id.
      URI: /locations/LOCATION
      @param [String] locationId The location id
      ###
      get: (locationId,cb) ->
        throw new Error "cb is a required parameter" unless cb and typeof cb is 'function'
        _invokeRequest "/locations/#{locationId}",{},cb

      ###
      Returns menu information for the specified location id.
      URI /locations/LOCATION/menu
      @param [String] locationId The location id
      ###
      getMenu: (locationId,cb) ->
        throw new Error "cb is a required parameter" unless cb and typeof cb is 'function'
        _invokeRequest "/locations/#{locationId}/menu",{},cb

      ###
      Returns short menu information for the specified location id.
      URI /locations/LOCATION/shortmenu
      @param [String] locationId The location id
      ###
      getShortMenu: (locationId,cb) ->
        throw new Error "cb is a required parameter" unless cb and typeof cb is 'function'
        _invokeRequest "/locations/#{locationId}/shortmenu",{},cb

  return c # Explicit return for readability - I know, but there are a lot of Coffeescript newbies out there.

