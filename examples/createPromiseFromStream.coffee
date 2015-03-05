# create a promise from a stream and print its first value

s = require "signalicious"

s.producer.every(100)
  .waitFor (val) -> val > 10
  .then console.log