events = require "events"

q = require "q"

module.exports = ->
  emitter = new events.EventEmitter()

  o = 
    push: (value) ->
      emitter.emit("data", value)

    close: ->
      emitter.emit "close"
      emitter.removeAllListeners()

    pipe: (f) ->
      s = module.exports()
      s.push = o.push
      emitter.on "data", (data) ->
        try
          f data, (value) ->
            s.push(value)

        catch e
          channels.error.push(e)

      emitter.on "close", ->
        s.close()

      s

    to: (stream) ->
      emitter.on "data", (data) -> stream.push(data)

    waitFor: (f) ->
      d = q.defer()

      emitter.on "data", (data) ->
        if f(data)
          emitter.removeListener "data", arguments.callee
          d.resolve(data)

      d.promise

  o

module.exports.fromEvent = (emitter, event) ->
  stream = module.exports()
  emitter.on event, (value) ->
    stream.push(value)

  stream


module.exports.every = (ms) ->
  stream = module.exports()

  i = 0
  setInterval((-> stream.push(i++)), ms)

  stream

channels = require "./channels"
