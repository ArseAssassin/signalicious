# read url from stdin, push response to stdout

http = require "http"

s = require "signalicious"

s.channels.stdin
  .pipe s.helpers.toString()
  .pipe (url, cb) ->
    http.request url, (res) ->
      cb s.producer.fromNodeStream res
    .end()
  .pipe s.helpers.exhaustStream()
  .pipe s.helpers.toString()
  .to s.channels.stdout
