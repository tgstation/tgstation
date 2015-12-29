c = require "../config"
f = c.flags
p = c.paths
g = c.plugins.gulp
s = c.plugins.postcss

gulp    = require "gulp"
postcss = require "postcss"

module.exports = ->
  gulp.src p.css.dir + p.css.main
    .pipe g.if(f.debug, g.sourcemaps.init({loadMaps: true}))
    .pipe g.stylus({url: 'data-url', paths: [p.img.dir]})
    .pipe g.postcss([
      s.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
      s.gradient,
      s.opacity,
      s.rgba({oldie: true}),
      s.plsfilters({oldIE: true}),
      s.fontweights
    ])
    .pipe g.concat(p.css.out)
    .pipe g.bytediff.start()
    .pipe g.if(f.colorblind, g.postcss([p.colorblind]))
    .pipe g.if(f.min, g.cssnano({autoprefixer: {browsers: ["last 2 versions", "ie >= 8"]}, discardComments: {removeAll: true}}))
    .pipe g.if(f.debug, g.sourcemaps.write(sourceRoot: "/source/styles/"))
    .pipe g.bytediff.stop()
    .pipe gulp.dest p.out
module.exports.displayName = "css"
