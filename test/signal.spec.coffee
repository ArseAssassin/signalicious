chai = require "chai"
expect = chai.expect

q = require "q"

signalicious = require "../lib/index"


describe "signal", ->
  beforeEach ->
    @signal = signalicious.signal(0)


  it ".value should return default value", ->
    expect(@signal.value()).to.equal 0


  it ".merge should merge input stream value", ->
    input = signalicious.stream()
    @signal.merge input, (i, value) -> i + value

    input.push 2
    input.push 2

    expect(@signal.value()).to.equal 4


  it ".blockUntil should call function when signal value passes condition", ->
    n = 0

    @signal.blockUntil (
      (i) -> i >= 5
    ), (value) -> n = value

    input = signalicious.stream()
    @signal.merge input, (i, value) -> i + 1

    [0..2].map input.push
    expect(n).to.equal 0

    [0..7].map input.push

    expect(n).to.equal 5


  it ".to should push new values to target", ->
    n = 0

    input = signalicious.stream()

    @signal
      .merge input, (i, value) -> i + 1
      .to push: (value) -> n = value

    [0..3].map input.push

    expect(n).to.equal 4


describe "signal.fromPromise", ->
  beforeEach ->
    @deferred = q.defer()
    @signal = signalicious.signal.fromPromise @deferred.promise

  it "should create a new signal from promise", ->
    expect(@signal.value().resolved).to.equal  false
    expect(@signal.value().value).to.equal     undefined

  it "should change value when promise is resolved", ->
    signal = @signal

    @deferred.resolve(1)
    @deferred.promise.then ->
      expect(signal.value().value).to.equal 1

  it "should report error when promise fails", ->
    signal = @signal

    @deferred.reject(1)
    @deferred.promise.fail ->
      expect(signal.value().error).to.equal 1

