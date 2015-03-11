errorChannel = require "./errorChannel"

module.exports =
  fromNodeStream: (writable) ->
    push: (data) -> 
      writable.write(data)

    handleError: (error) ->
      errorChannel.push error