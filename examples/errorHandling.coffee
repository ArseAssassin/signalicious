# recovering from an error

s = require "signalicious"

s.stream()
  .pipe -> throw new Error("Start propagating forward")
  .pipe -> "This is never called"
  .recover (error, cb) -> cb error.data
  .to s.channels.stdout

  .push "This is recovered"

