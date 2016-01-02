c = require "../config"
p = c.paths

debounce = require "debounce"
gulp     = require "gulp"

build  = require "./build"
clean  = require "./clean"
reload = require "./reload"


module.exports = ->
  paths = []
  for i,path of p
    paths.push "#{path.dir}**" if path.dir

  gulp.watch paths, debounce(gulp.series(clean, build, reload), 1000)
module.exports.displayName = "watch"
