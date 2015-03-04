# block stream until a promise is resolved, then print all values

s = require "signalicious"

stream = s.stream.every(100)

promise = stream.waitFor (val) -> val > 5

stream
  .pipe s.helpers.blockPromise s.signal.fromPromise(promise)
  .pipe (data) -> console.log data