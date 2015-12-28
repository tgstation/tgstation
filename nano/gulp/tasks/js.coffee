c = require "../config"
f = c.flags
p = c.paths
b = c.plugins.browserify
g = c.plugins.gulp


browserify = require "browserify"
gulp       = require "gulp"
through    = require "through2"


aliasify =
  aliases:
    templates: "./templates"
    components: "./components"

bundle = ->
  through.obj (file, enc, next) ->
    browserify file.path,
      extensions: [".coffee"]
      debug: f.debug
    .transform b.coffeeify
    .transform b.aliasify, aliasify
    .transform b.componentify
    .bundle (err, res) ->
      return next err if err
      file.contents = res
      next null, file

module.exports = ->
  gulp.src p.input.scripts
    .pipe bundle()
    .pipe g.if(f.debug, g.sourcemaps.init({loadMaps: true}))
    .pipe g.concat(p.output.js)
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}}))
    .pipe g.if(f.debug, g.sourcemaps.write())
    .pipe g.bytediff.stop()
    .pipe gulp.dest p.output.dir
module.exports.displayName = "js"
