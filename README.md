# signalicious
Signalicious event processing for Node

## Quick start

To install 

``` 
npm install signalicious
```

### Streams

```coffeescript
# capitalizing a string through a stream

s = require "signalicious"

stream = s.stream()
  .pipe (data, cb) -> cb data.toUpperCase()
  .pipe s.helpers.log()

stream.push("hello world")
```

### Signals

```coffeescript
# create a signal that counts up every second and print the value

s = require "signalicious"

add = s.stream.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1
  
counter.to s.stream().pipe s.helpers.log()
```

### Promises

```coffeescript
# create a promise from a stream and print its first value

s = require "signalicious"

stream = s.stream.every(100)

promise = stream.waitFor (val) -> val > 10

promise.then console.log
```

```coffeescript
# block stream until a promise is resolved, then print all values

s = require "signalicious"

stream = s.stream.every(100)

promise = stream.waitFor (val) -> val > 5

stream
  .pipe s.helpers.blockPromise s.signal.fromPromise(promise)
  .pipe (data) -> console.log data

```

