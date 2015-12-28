c = require "../config"
f = c.flags
p = c.paths
g = c.plugins.gulp

gulp = require "gulp"


module.exports = ->
  gulp.src p.input.html
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.htmlmin({collapseWhitespace: true, minifyJS: true, minifyCSS: true, quoteCharacter: "'"}))
    .pipe g.bytediff.stop()
    .pipe gulp.dest p.output.dir
module.exports.displayName = "html"
