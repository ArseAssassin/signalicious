stream = require "./stream"

module.exports =
  fromNodeStream: (readable) ->
    s = stream()

    readable.on "data", s.push
    readable.on "close", s.close

    s
