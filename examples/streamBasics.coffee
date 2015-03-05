# capitalize string from stdin

s = require "signalicious"

s.channels.stdin
  .pipe (data, cb) -> cb data.toString().toUpperCase()
  .to s.channels.stdout

