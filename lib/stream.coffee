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
      pipePush = s.push
      s.push = o.push
      emitter.on "data", (data) ->
        try
          f data, (value) ->
            pipePush(value)

        catch e
          channels.error.push(e)

      emitter.on "close", ->
        s.close()

      s

    to: (stream) ->
      if !stream.push
        throw new Error("Object doesn't implement push - might not be a Signalicious stream")

      emitter.on "data", (data) -> stream.push(data)

      o

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
