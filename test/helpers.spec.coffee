chai = require "chai"
expect = chai.expect

q = require "q"

signalicious = require "../lib/index"
helpers = signalicious.helpers


describe "helpers", ->
  beforeEach ->
    @signal = signalicious.signal(0)
    @stream = signalicious.stream()

  it ".block should let stream pass through when signal has acceptable value", ->
    n = 0
    @stream
      .pipe signalicious.helpers.block @signal, (it) -> it == 1
      .pipe (it) -> n = it

    @stream.push 10
    expect(n).to.equal 0

    input = signalicious.stream()
    @signal.merge input, (value, newValue) -> newValue
    input.push 1

    expect(n).to.equal 10


  it ".blockPromise should block stream until signal based on promise has been resolved", ->
    n = 0

    d = q.defer()
    signal = signalicious.signal.fromPromise(d.promise)

    @stream
      .pipe helpers.blockPromise(signal)
      .pipe (it) -> n = it

    @stream.push 10

    expect(n).to.equal 0

    d.resolve(10)
    d.promise.then ->
      expect(n).to.equal 10


  it ".id should return its first argument", ->
    expect(helpers.id(1)).to.equal 1


  it ".resolvePromise should block stream until promise has been resolved", ->
    n = 0
    d = q.defer()

    @stream
      .pipe helpers.resolvePromise d.promise
      .pipe (it) -> n = it
    @stream.push d.promise

    d.resolve(1)

    expect(n).to.equal 0
    d.promise.then (x) ->
      expect(n).to.equal 1


  it ".sync should convert async function to synchronous one", ->
    n = 0

    @stream
      .pipe helpers.sync (i) -> i + 1
      .pipe -> n = 10

    @stream.push 1

    expect(n).to.equal 10

  it ".toString will convert its argument to string", ->
    n = false

    @stream
      .pipe helpers.toString()
      .pipe (it) -> n = typeof it == "string"

    @stream.push 1

    expect(n).to.equal true

  it ".add should add its argument to stream", ->
    n = 0

    @stream
      .pipe helpers.add(1)
      .pipe (it) -> n = it

    @stream.push 1

    expect(n).to.equal 2

  it "intercalate should intercalate stream values with its argument", ->
    n = ""

    @stream
      .pipe helpers.intercalate("-")
      .pipe (it) -> n += it

    @stream.push "1"

    expect(n).to.equal "1"

    @stream.push "2"
    @stream.push "3"

    expect(n).to.equal "1-2-3"
