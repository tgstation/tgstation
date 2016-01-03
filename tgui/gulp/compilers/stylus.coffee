stylus = require "stylus"


module.exports = (source, file) ->
  source = stylus source
    .set "filename", file
  output =
    source: source.render()
  output
