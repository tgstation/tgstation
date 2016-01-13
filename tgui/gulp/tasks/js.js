import * as f from '../flags'
import * as p from '../paths'
import { browserify as b, gulp as g } from '../plugins'

import { transform as babel } from 'babel-core'
import { readFileSync as read } from 'fs'
b.componentify.compilers['text/javascript'] = function (source, file) {
  const config = { sourceMaps: true }
  Object.assign(config, JSON.parse(read('.babelrc', 'utf8')))
  const compiled = babel(source, config)

  return {
    source: compiled.code,
    map: compiled.map
  }
}

import browserify from 'browserify'
const bundle = browserify(p.js.dir + p.js.main, {
  debug: f.debug,
  cache: {},
  extensions: ['.js', '.ract']
})
.plugin(b.rememberify)
.transform(b.babelify)
.plugin(b.helpers)
.transform(b.componentify)
.transform(b.globify)
.transform(b.es3ify)
if (f.min) {
  bundle.plugin(b.collapse)
}

import buffer from 'vinyl-buffer'
import gulp from 'gulp'
import source from 'vinyl-source-stream'
export function js () {
  return bundle.bundle()
    .pipe(source('bundle'))
    .pipe(buffer())
    .pipe(g.if(f.debug, g.sourcemaps.init({loadMaps: true})))
    .pipe(g.rename(p.js.out))
    .pipe(g.bytediff.start())
    .pipe(g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}})))
    .pipe(g.if(f.debug, g.sourcemaps.write()))
    .pipe(g.bytediff.stop())
    .pipe(gulp.dest(p.out))
}
export function watch_js () {
  return gulp.watch(p.js.dir + '**', vinyl => {
    b.rememberify.forget(bundle, vinyl.path)
    return js()
  })
}
