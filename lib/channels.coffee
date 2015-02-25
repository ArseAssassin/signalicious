stream = require "./stream"
producer = require "./producer"
consumer = require "./consumer"
helpers = require "./helpers"

stdout = consumer.fromNodeStream(process.stdout)

module.exports =
  stdin: producer.fromNodeStream(process.stdin)
  stdout: stdout
  stderr: consumer.fromNodeStream(process.stderr)
  error: stream()
  log: stream()
    .pipe helpers.toString()
    .pipe helpers.add("\n")
    .to stdout

  enableErrorLogging: ->
    module.exports.error
      .pipe (error, cb) ->
        cb error.stack || new Error().stack
      .to module.exports.stderr