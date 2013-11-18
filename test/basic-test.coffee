should = require 'should'
nconf = require 'nconf'

describe 'WHEN loading the module', ->
  index = require '../lib/index'

  it 'should exist', ->
    should.exist index

