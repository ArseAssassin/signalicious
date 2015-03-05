# shows system clock

s = require "signalicious"

pad = (x) ->
  s = x.toString()
  while s.length <= 1
    s = "0" + s

  s

s.producer.every(1000)
  .pipe (d, cb) -> cb new Date
  .pipe (d, cb) -> cb "#{pad d.getHours()}:#{pad d.getMinutes()}:#{pad d.getSeconds()}"
  .pipe s.helpers.prepend `'\033[2J'`
  .to s.channels.log