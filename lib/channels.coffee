stream = require "./stream"

module.exports =
  error: stream()
  enableErrorLogging: ->
    module.exports.error.pipe (error) ->
      console.error(error.stack)
      console.error(error.toString())