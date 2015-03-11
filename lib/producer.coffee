stream = require "./stream"

module.exports =
  fromNodeStream: (readable) ->
    s = stream()
    readable.on "data", s.push
    readable.on "close", s.close
    readable.on "end", s.close
    s

  every: (ms) ->
    s = stream()
    i = 0
    setInterval (-> s.push i++), ms
    s

