gulp = require "gulp"

css  = require "./css"
html = require "./html"
js   = require "./js"
size = require "./size"

module.exports = gulp.series (gulp.parallel css, html, js), size
