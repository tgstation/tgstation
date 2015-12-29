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
    dom4: "dom4/build/dom4.max"
    ie8: "ie8/build/ie8.max"
    ractive: "ractive/ractive.runtime"
    "es5-sham": "es5-shim/es5-sham"
  replacements: {}

b.componentify.compilers["text/coffeescript"] = require "../compilers/coffeescript"

bundle = ->
  through.obj (file, enc, next) ->
    browserify file.path,
      extensions: [".coffee", ".ract"]
      debug: f.debug
    .transform b.coffeeify
    .transform b.componentify
    .transform b.aliasify, aliasify
    .transform b.globify
    .bundle (err, res) ->
      return next err if err
      file.contents = res
      next null, file

module.exports = ->
  gulp.src p.js.dir + p.js.main
    .pipe bundle()
    .pipe g.if(f.debug, g.sourcemaps.init({loadMaps: true}))
    .pipe g.concat(p.js.out)
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}}))
    .pipe g.if(f.debug, g.sourcemaps.write())
    .pipe g.bytediff.stop()
    .pipe gulp.dest p.out
module.exports.displayName = "js"
