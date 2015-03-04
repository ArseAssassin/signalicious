# create a promise from a stream and print its first value

s = require "signalicious"

stream = s.stream.every(100)

promise = stream.waitFor (val) -> val > 10

promise.then console.log