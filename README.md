# Signalicious
Signalicious is a functional reactive programming library focusing on simplicity. It's built around two main concepts: signals and streams.

## Stream

A stream is essentially a pipe in which data moves forward. The idea is basically the same as Unix pipelines: data is piped from operation to operation until it's consumed. Typically you'd source a stream from an event, for example a button click.

## Signal

A signal is essentially a mutable value. It has a starting value and streams merge into it to mutate its state. To model a counter, you'd set its starting value as 0 and then merge the increment stream into it.

## Quick start

To install 

``` 
npm install signalicious
```

### Streams

```coffeescript
# capitalize string from stdin

s = require "signalicious"

# make sure that errors thrown during piping are logged to stderr
s.channels.enableErrorLogging()

s.channels.stdin
  .pipe (data, cb) -> cb data.toString().toUpperCase()
  .to s.channels.stdout
```

### Signals

```coffeescript
# create a signal that counts up every second and print the value

s = require "signalicious"

add = s.producer.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1
  .to s.channels.log
```

## Error handling

When a pipe encounters an error, it's caught by the stream and propagated forward until the consumer's handleError function is called. You can recover from an error by calling .recover on the pipe:

```coffeescript
# recovering from an error

s = require "signalicious"

s.stream()
  .pipe -> throw new Error("Start propagating forward")
  .pipe -> "This is never called"
  .recover (error, cb) -> cb error.data
  .to s.channels.stdout

  .push "This is recovered"
```

If the error is never recovered, Signalicious consumers will push error messages to signalicious.channels.error. You should call signalicious.channels.enableErrorLogging at the start of your program to make sure that errors will be propagated to stderr.

The error object propagated to the recovery function has the following properties:
  error: the error object thrown
  path: the path of the data packet through your program - an array including line numbers and file names
  data: the data being piped before your program encountered an error
