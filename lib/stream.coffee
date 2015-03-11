events = require "events"
_ = require "underscore-contrib"

q = require "q"

currentFileDir = __dirname

resolveContext = ->
  stack = new Error().stack.split("\n")
    .filter((it) -> it.indexOf(currentFileDir) == -1)
  stack[1]

stream = ->
  context = resolveContext()
  emitter = new events.EventEmitter
  closed = false

  o = 
    push: (value, path) ->
      path = if path
        [context].concat path
      else
        [context]

      emitter.emit("data", value, path)

    close: ->
      emitter.emit "close"
      emitter.removeAllListeners()

    onClose: (f) ->
      emitter.on "close", f

    handleError: (error) ->
      emitter.emit "streamError", _.merge error,
        path: [context].concat(error.path)

    pipe: (f) ->
      pipedStream = stream()

      next              = pipedStream.push
      pipedStream.push  = o.push
      f.next            = next

      emitter.on "data", (data, path) ->
        try
          f data, (value) ->
            next(value, path)

        catch e
          pipedStream.handleError
            data:  data
            error: e
            path:  path

      emitter.on "close", ->
        if f.onClose
          f.onClose()
        pipedStream.close()

      emitter.on "streamError", (error) ->
        pipedStream.handleError error

      pipedStream

    recover: (f) ->
      handler = (data, cb) -> cb data

      recoveryStream = o.pipe handler
      recoveryStream.handleError = (error) ->
        f error, (value) -> handler.next(value, error.path)

      recoveryStream

    to: (stream) ->
      if !stream.push
        throw new Error("Object doesn't implement push - might not be a Signalicious stream")
      if !stream.handleError
        throw new Error("Object doesn't implement handleError - might not be a Signalicious stream")

      emitter.on "data", stream.push
      emitter.on "streamError", stream.handleError

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
