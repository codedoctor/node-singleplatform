should = require 'should'
config = require 'nconf'
fs = require 'fs'
path = require 'path'

###
Well, those "tests" here are just quick and dirty. Feel free to improve, dear reader ;-)
###

path = path.join __dirname, '../config/test.json'
settings = null

if fs.existsSync path
  config.file file: path
  settings = config.get()

describe 'WHEN loading the module', ->
  index = require '../lib/index'

  it 'should exist', ->
    should.exist index

  if settings
    console.log "SETTINGS LOADED FOR #{settings.referer} - LIVE TEST"

    it 'should instantiate a client', ->
      client = index.client(settings)
      should.exist client
      should.exist client.locations
      should.exist client.locations.search
      should.exist client.locations.get
      should.exist client.locations.getMenu
      should.exist client.locations.getShortMenu

    it 'should return search results', (cb) ->
      client = index.client(settings)
      client.locations.search 'Haru',0,20,null, (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err

    it 'should return search results for queries with space in it.', (cb) ->
      client = index.client(settings)
      client.locations.search 'Haru Sushi',0,20,null, (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err

    it 'should return a location', (cb) ->
      client = index.client(settings)
      client.locations.get 'haru-7', (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err

    it 'should return a menu', (cb) ->
      client = index.client(settings)
      client.locations.getMenu 'haru-7', (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err

    it 'should return a short menu', (cb) ->
      client = index.client(settings)
      client.locations.getShortMenu 'haru-7', (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err

    it 'should match stuff', (cb) ->
      client = index.client(settings)
      matchData = 
        locations:[
                "address":"2047 US Highway 45 Byp S Trenton TN 38382"
                "name":"Dairy Queen"
              ,
                "address":"1125 W Riverdale Road Riverdale Utah"
                "name":"Applebees Neighborhood Grill"
              ,
                "address":"15479 Hwy. One Marshall California"
                "name":"Tomales Bay Oyster Company"
              ,
                "address":"1825 Washington Rd, Washington PA 15301"
                "name":"Primo"
          ]
        matching_criteria:"NAME_ADDRESS"
 

      client.locationMatch matchData, (err,data) ->
        console.log "RESULT: #{JSON.stringify(data)}"
        cb err