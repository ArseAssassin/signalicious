stream = require "./stream"
producer = require "./producer"
consumer = require "./consumer"

module.exports =
  stdin: producer.fromNodeStream(process.stdin)
  stdout: consumer.fromNodeStream(process.stdout)
  stderr: consumer.fromNodeStream(process.stderr)
  error: stream()
  enableErrorLogging: ->
    module.exports.error
      .pipe (error, cb) ->
        cb error.stack || new Error().stack
      .to module.exports.stderr