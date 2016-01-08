c = require "../config"
f = c.flags
p = c.paths
b = c.plugins.browserify
g = c.plugins.gulp

babel      = require "babel-core"
browserify = require "browserify"
gulp       = require "gulp"
through    = require "through2"

b.componentify.compilers["text/javascript"] = (source, file) ->
  config = { sourceMaps: true }
  Object.assign config, JSON.parse(require('fs').readFileSync(".babelrc", "utf8"))
  compiled = babel.transform source, config

  output =
    source: compiled.code
    map: compiled.map

bundle = ->
  through.obj (file, enc, next) ->
    browserify file.path,
      extensions: [".js", ".ract"]
      debug: f.debug
    .transform b.babelify
    .plugin b.helpers
    .transform b.componentify
    .transform b.globify
    .bundle (err, res) ->
      return next err if err
      file.contents = res
      next null, file

module.exports = ->
  gulp.src p.js.dir + p.js.main
    .pipe bundle()
    .pipe g.if(f.debug, g.sourcemaps.init({loadMaps: true}))
    .pipe g.rename(p.js.out)
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}}))
    .pipe g.if(f.debug, g.sourcemaps.write())
    .pipe g.bytediff.stop()
    .pipe gulp.dest p.out
module.exports.displayName = "js"
