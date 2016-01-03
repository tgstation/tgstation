coffee = require "coffee-script"


module.exports = (source, file) ->
  compiled = coffee.compile source,
    bare: true
    sourceMap: true
    inline: true

  output =
    source: compiled.js
    map: JSON.parse compiled.v3SourceMap
  output
