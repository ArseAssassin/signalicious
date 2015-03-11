fs = require "fs"

s = require "signalicious"

s.producer.fromNodeStream fs.createReadStream process.argv[process.argv.length - 1]
  .to s.channels.stdout