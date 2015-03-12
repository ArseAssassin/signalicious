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

  it ".onClose should be fired when stream is closed", ->
    n = 0

    @stream.onClose -> n = 1
    @stream.close()

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

  it "should add path trace to any data pushed through", ->
    n = ""

    @stream
      .pipe (data, cb) -> cb data
      .to
        push: (value, path) -> 
          n = path
        handleError: ->

    @stream.push 1

    expect(n.length).to.equal 2

  describe "errors", ->
    it "should propagate errors to next recovery", ->
      n = 0

      @stream
        .pipe -> throw new Error("error")
        .pipe -> n = 2
        .recover (error) -> n = error.data
        
      @stream.push 1

      expect(n).to.equal 1

    it "should continue if error handler calls cb", ->
      n = 0

      @stream
        .pipe -> throw new Error("error")
        .recover (error, cb) -> cb error.data
        .pipe (it) -> n = it

      @stream.push 1

      expect(n).to.equal 1

    it "should propagate errors between streams", ->
      n = 0
      second = signalicious.stream()
        .recover (error) -> n = error.data

      @stream
        .pipe -> throw new Error("error")
        .to second

      @stream.push 1

      expect(n).to.equal 1
      

