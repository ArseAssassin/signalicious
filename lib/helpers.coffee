module.exports = 
  block: (signal, f) -> (data, cb) ->
    signal.blockUntil f, -> cb(data)

  blockPromise: (signal) -> (data, cb) ->
    signal.blockUntil ((it) -> it.resolved), -> cb(data)

  id: (it) -> it

  resolvePromise: () -> (data, cb) ->
    data.then cb

  sync: (f) -> (data, cb) ->
    cb f(data)

  log: () -> (data, cb) ->
    console.log data
    cb data

  toString: () -> (data, cb) ->
    cb data.toString()