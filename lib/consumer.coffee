stream = require "./stream"

module.exports =
  fromNodeStream: (writable) ->
    push: (data) -> 
      writable.write(data)