# signalicious
Signalicious event processing for Node

## Quick start

To install 

``` 
npm install signalicious
```

### Streams

```coffeescript
# capitalize string from stdin

s = require "signalicious"

s.channels.stdin
  .pipe (data, cb) -> cb data.toString().toUpperCase()
  .to s.channels.stdout
```

### Signals

```coffeescript
# create a signal that counts up every second and print the value

s = require "signalicious"

s.channels.enableErrorLogging()

add = s.producer.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1
  .to s.channels.log
```

### Promises

```coffeescript
# create a promise from a stream and print its first value

s = require "signalicious"

s.producer.every(100)
  .waitFor (val) -> val > 10
  .then console.log
```

```coffeescript
# block stream until a promise is resolved, then print all values

s = require "signalicious"

stream = s.producer.every(100)

promise = stream.waitFor (val) -> val > 5

stream
  .pipe s.helpers.blockPromise s.signal.fromPromise(promise)
  .to s.channels.log
```

