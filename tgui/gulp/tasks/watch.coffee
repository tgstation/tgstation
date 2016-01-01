c = require "../config"
p = c.paths

gulp = require "gulp"

build  = require "./build"
clean  = require "./clean"
reload = require "./reload"


module.exports = ->
  paths = []
  for i,path of p
    paths.push "#{path.dir}**" if path.dir

  gulp.watch paths, gulp.series clean, build, reload
module.exports.displayName = "watch"
