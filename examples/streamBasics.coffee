# capitalize string from stdin

s = require "signalicious"

# make sure that errors thrown during piping are logged to stderr
s.channels.enableErrorLogging()

s.channels.stdin
  .pipe (data, cb) -> cb data.toString().toUpperCase()
  .to s.channels.stdout

