###
singleplatform primary entry point
###

client = require './client'

module.exports =

  ###
  The actual client. 
  To be invoked like this:
  @example
    ```coffeescript
    singleplatform = require 'singleplatform'
    client = singleplatform.client 
      apiKey:

    client.doStuff ...
    ```

  ###
  client : client
