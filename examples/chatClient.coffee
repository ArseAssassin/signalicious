# basic chat client with engine.io
# install engine.io-client to run

eio = require "engine.io-client"

signalicious = require "signalicious"

socket = new eio.Socket("ws://localhost:4444/")

name = signalicious.signal("guest")
  .merge (
    signalicious.channels.stdin
      .pipe signalicious.helpers.take 1
  ), (value, it) -> it.toString().replace("\n", "")

signalicious.channels.log.push "What's your name?"

signalicious.producer.fromEvent socket, "message"
  .to signalicious.channels.stdout

signalicious.channels.stdin
  .pipe signalicious.helpers.drop 1
  .pipe signalicious.helpers.toString()
  .to
    push: (message) ->
      socket.send (name.value() + ": " + message)
    handleError: signalicious.channels.error.push