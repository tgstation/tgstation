c = require "../config"
p = c.paths

del = require "del"


module.exports = ->
  del "#{p.output.dir}/*"
module.exports.displayName = "clean"
