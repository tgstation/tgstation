import * as f from '../flags'
import * as p from '../paths'
import { browserify as b, gulp as g } from '../plugins'

import { transform as babel } from 'babel-core'
import { readFileSync as read } from 'fs'
b.componentify.compilers['text/javascript'] = function (source, file) {
  let config = { sourceMaps: true }
  Object.assign(config, JSON.parse(read('.babelrc', 'utf8')))
  let compiled = babel(source, config)

  return {
    source: compiled.code,
    map: compiled.map
  }
}

import browserify from 'browserify'
import through from 'through2'
const bundle = function () {
  return through.obj((file, enc, next) => {
    let bundle = browserify(file.path, { extensions: ['.js', '.ract'], debug: f.debug })
      .transform(b.babelify)
      .plugin(b.helpers)
      .transform(b.componentify)
      .transform(b.globify)
    if (f.min) {
      bundle.plugin(b.collapse)
    }
    bundle.bundle((err, res) => {
      if (err) next(err)
      file.contents = res
      next(null, file)
    })
  })
}

import gulp from 'gulp'
module.exports = function () {
  return gulp.src(p.js.dir + p.js.main)
    .pipe(bundle())
    .pipe(g.if(f.debug, g.sourcemaps.init({loadMaps: true})))
    .pipe(g.rename(p.js.out))
    .pipe(g.bytediff.start())
    .pipe(g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}})))
    .pipe(g.if(f.debug, g.sourcemaps.write()))
    .pipe(g.bytediff.stop())
    .pipe(gulp.dest(p.out))
}
module.exports.displayName = 'js'
