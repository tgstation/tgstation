c = require "../config"
p = c.paths
g = c.plugins.gulp

gulp = require "gulp"

module.exports = ->
  gulp.src "#{p.out}/*"
    .pipe g.size()
module.exports.displayName = "size"
