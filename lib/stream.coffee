events = require "events"

q = require "q"

stream = ->
  emitter = new events.EventEmitter
  closed = false

  o = 
    push: (value) ->
      emitter.emit("data", value)

    close: ->
      emitter.emit "close"
      emitter.removeAllListeners()

    pipe: (f) ->
      pipedStream = stream()

      next              = pipedStream.push
      pipedStream.push  = o.push

      emitter.on "data", (data) ->
        try
          f data, (value) ->
            next(value)

        catch e
          channels.error.push(e)

      emitter.on "close", ->
        pipedStream.close()

      pipedStream

    to: (stream) ->
      if !stream.push
        throw new Error("Object doesn't implement push - might not be a Signalicious stream")

      emitter.on "data", stream.push

      o

    waitFor: (f) ->
      d = q.defer()

      emitter.on "data", (data) ->
        if f(data)
          emitter.removeListener "data", arguments.callee
          d.resolve(data)

      d.promise

  o


stream.fromEvent = (emitter, event) ->
  eventStream = module.exports()
  emitter.on event, eventStream.push

  eventStream


module.exports = stream

channels = require "./channels"