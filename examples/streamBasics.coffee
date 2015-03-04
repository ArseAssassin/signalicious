# capitalizing a string through a stream

s = require "signalicious"

stream = s.stream()
  .pipe (data, cb) -> cb data.toUpperCase()
  .pipe s.helpers.log()

stream.push("hello world")