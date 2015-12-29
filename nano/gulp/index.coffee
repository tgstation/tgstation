gulp = require "gulp"

build  = require "./tasks/build"
clean  = require "./tasks/clean"
reload = require "./tasks/reload"


gulp.task clean
gulp.task "update", gulp.series clean, build, reload
gulp.task "default", gulp.series clean, build
