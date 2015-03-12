# Signalicious
Signalicious is a functional reactive programming library focusing on simplicity. It's built around two main concepts: signals and streams.

## Quick start

To install 

``` 
npm install signalicious
```

### Streams

A stream is essentially a pipe in which data moves forward. The idea is basically the same as Unix pipelines: data is piped from operation to operation until it's consumed. Typically you'd source a stream from an event, for example a button click.


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

A signal is essentially a mutable value. It has a starting value and streams merge into it to mutate its state. To model a counter, you'd set its starting value as 0 and then merge the increment stream into it.

```coffeescript
# create a signal that counts up every second and print the value

s = require "signalicious"

add = s.producer.every(1000)

counter = s.signal(0)
  .merge add, (value, frame) -> value + 1
  .to s.channels.log
```

## Producers

Producer is a stream that produces values without values being pushed to it. The following producers are available:

    fromNodeStream(stream): takes a Node stream object and returns a stream
    
    every(ms): pushes an incrementing value every ms milliseconds
    
    fromEvent(emitter, name): takes an event emitter and an event name; every time the emitter emits event of name, push the first argument to the stream
    
    
## Consumer

Consumer is a stream that consumes any values pushed to it. The following consumers are available:

    fromNodeStream(stream): takes a writable Node stream and writes any values pushed to it - errors are pushed to signalicious.channels.error

## Channels

Some standard streams are available in signalicious.channels

    stdin: reads values from stdin
    
    stdout: writes values it consumes to stdout - only accepts strings
    
    stderr: writes values it consumes to stderr - only accepts strings
    
    error: does nothing by default, when enableErrorLogging is called, writes error messages to stderr when errors are encountered during piping
    
    log: stringifies values and appends a newline to them - basically acts like console.log for streams

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
