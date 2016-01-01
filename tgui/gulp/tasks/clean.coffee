c = require "../config"
p = c.paths

del = require "del"


module.exports = ->
  del "#{p.out}/*"
module.exports.displayName = "clean"
