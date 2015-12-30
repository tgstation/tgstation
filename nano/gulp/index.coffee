gulp = require "gulp"

build  = require "./tasks/build"
clean  = require "./tasks/clean"
reload = require "./tasks/reload"
watch  = require "./tasks/watch"


gulp.task clean
gulp.task "default", gulp.series clean, build
gulp.task "update", gulp.series clean, build, reload
gulp.task watch
