module.exports = 
  block: (signal, f) -> (data, cb) ->
    signal.blockUntil f, -> cb(data)

  blockPromise: (signal) -> (data, cb) ->
    signal.blockUntil ((it) -> it.resolved), -> cb(data)

  id: (it) -> it

  resolvePromise: () -> (promise, cb) ->
    promise.then (data) -> cb(data); data

  exhaustStream: () -> (stream, cb) ->
    stream.to push: cb

  sync: (f) -> (data, cb) ->
    cb f(data)

  log: () -> (data, cb) ->
    console.log data
    cb data

  toString: () -> (data, cb) ->
    cb data.toString()

  add: (glue) -> (data, cb) ->
    cb (data + glue)

  prepend: (glue) -> (data, cb) ->
    cb (glue + data)

  intercalate: (glue) -> 
    first = true
    (data, cb) ->
      if first
        first = false
        cb data
      else
        cb glue
        cb data