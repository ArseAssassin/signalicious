# create a signal that counts up every second and print the value

s = require "signalicious"

s.channels.enableErrorLogging()

add = s.producer.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1
  .to s.channels.log
