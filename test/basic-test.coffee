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


