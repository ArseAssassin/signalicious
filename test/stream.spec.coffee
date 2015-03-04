events = require "events"

chai = require "chai"
expect = chai.expect

q = require "q"

signalicious = require "../lib/index"


describe "stream", ->
  beforeEach ->
    @stream = signalicious.stream()

  it "should pipe pushed values through functions", ->
    n = 0

    @stream.pipe (value) -> n = value
    @stream.push 1

    expect(n).to.equal 1

  it "should stop pushing new values after stream has been closed", ->
    n = 0

    @stream.pipe (value) -> n = value
    @stream.close()
    @stream.push 1

    expect(n).to.equal 0


  it "should push errors thrown during piping to channels.error", ->
    n = 0

    errorHandler = signalicious.stream().pipe (value) -> n = 1
    signalicious.channels.error.to errorHandler

    @stream.pipe -> throw new Error("error")
    @stream.push 1

    expect(n).to.equal 1


  it ".to should push values from one stream to another", ->
    n = 0

    secondStream = signalicious.stream().pipe (data) -> n = data
    @stream.to secondStream

    @stream.push 1

    expect(n).to.equal 1


  it ".waitFor should create a promise from stream", ->
    n = 0

    producer = signalicious.producer.every(10)
    producer
      .waitFor (it) -> n = it; it >= 3
      .then ->
        expect(n).to.equal 3
        producer.close()

describe "stream.fromEvent", ->
  it "should push to returned stream every time event is emitted", ->
    n = 0

    emitter = new events.EventEmitter

    stream = signalicious.stream.fromEvent(emitter, "activate")
    stream.pipe (data) -> n = data

    emitter.emit "activate", 1

    expect(n).to.equal 1