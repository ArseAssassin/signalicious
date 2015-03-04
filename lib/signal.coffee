events = require "events"

stream = require "./stream"
helpers = require "./helpers"

module.exports = (initialValue) ->
  value = initialValue
  emitter = new events.EventEmitter

  setValue = (newValue) ->
    value = newValue
    emitter.emit "data", value

  o =
    merge: (stream, f) ->
      stream.to push: (data, cb) ->
        setValue f(value, data)

      o

    emitter: emitter

    value: -> value

    blockUntil: (f, cb) ->
      if f(value)
        cb(value)
      else
        emitter.on "data", (val) ->
          if f(val)
            emitter.removeListener "data", arguments.callee
            cb(val)

    to: (stream) ->
      emitter.on "data", stream.push

  o


module.exports.fromPromise = (promise) ->
  input = stream()
  errors = stream()

  s = module.exports(resolved: false, value: undefined)
    .merge input, (value, data) -> resolved: true, value: data
    .merge errors, (value, error) -> resolved: true, error: error

  promise.then (value) ->
    input.push value

  promise.fail (error) ->
    errors.push error

  s

