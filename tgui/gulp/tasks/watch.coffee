c = require "../config"
p = c.paths

debounce = require "debounce"
gulp     = require "gulp"

build  = require "./build"
clean  = require "./clean"
reload = require "./reload"


module.exports = ->
  gulp.watch(
    Object.keys(p).filter((path) -> p[path].dir?).map((path) -> p[path].dir + "**"),
    debounce gulp.series(clean, build, reload), 1000
  )
module.exports.displayName = "watch"
