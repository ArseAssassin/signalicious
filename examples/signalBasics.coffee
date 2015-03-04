# create a signal that counts up every second and print the value

s = require "signalicious"

add = s.stream.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1

counter.to s.stream().pipe s.helpers.log()