# basic chat server with engine.io
# install engine.io to run

eio = require "engine.io"

signalicious = require "signalicious"
sync = signalicious.helpers.sync

stream = signalicious.stream

server = eio.listen(4444)

connections = signalicious.producer.fromEvent server, "connection"
  .pipe (socket, cb) ->
    messages.to
      push: (message) ->
        socket.send message.toString()
      handleError: signalicious.channels.error.push

    signalicious.producer.fromEvent socket, "message"
      .to messages

    signalicious.producer.fromEvent socket, "close"
      .pipe sync -> socket
      .to disconnections

disconnections = stream()

messages = stream()
  .to
    push: (message) ->
      users.value().map (user) -> user.send message
    handleError: signalicious.channels.error.push

messages.to signalicious.channels.stdout

users = signalicious.signal([])
  .merge connections, (value, it) -> value.concat it
  .merge disconnections, (value, it) -> value.filter (x) -> x != it

