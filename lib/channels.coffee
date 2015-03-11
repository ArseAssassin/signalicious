stream = require "./stream"
producer = require "./producer"
consumer = require "./consumer"
helpers = require "./helpers"
errorChannel = require "./errorChannel"

stdout = consumer.fromNodeStream(process.stdout)

module.exports =
  stdin: producer.fromNodeStream(process.stdin)
  stdout: stdout
  stderr: consumer.fromNodeStream(process.stderr)
  error: errorChannel
  log: stream()
    .pipe helpers.toString()
    .pipe helpers.add("\n")
    .to stdout

  enableErrorLogging: ->
    errorChannel
      .pipe (error, cb) ->
        cb error.error.stack + "\nPath: " + error.path.join("\n")
      .to module.exports.stderr