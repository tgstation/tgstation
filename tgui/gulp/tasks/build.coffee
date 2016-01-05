gulp = require "gulp"

css  = require "./css"
js   = require "./js"
size = require "./size"

module.exports = gulp.series (gulp.parallel css, js), size
