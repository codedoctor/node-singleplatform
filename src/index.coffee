###
singleplatform primary entry point
###

client = require './client'

module.exports =

  ###
  The actual client. 
  @example How to be used
    ```coffeescript
    singleplatform = require 'singleplatform'
    client = singleplatform.client 
      apiKey:

    client.doStuff ...
    ```

  ###
  client : client
