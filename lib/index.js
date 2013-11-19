/*
singleplatform primary entry point
*/


(function() {
  var client;

  client = require('./client');

  module.exports = {
    /*
    The actual client. 
    @example How to be used
      ```coffeescript
      singleplatform = require 'singleplatform'
      client = singleplatform.client 
        apiKey:
    
      client.doStuff ...
      ```
    */

    client: client
  };

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/