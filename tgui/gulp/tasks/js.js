import * as f from '../flags'
import { browserify as b, gulp as g } from '../plugins'

const dir = 'generated'
const entry = 'tgui.js'
const out = 'assets'

import { transform as babel } from 'babel-core'
import { readFileSync as read } from 'fs'
b.componentify.compilers['text/javascript'] = function (source, file) {
  const config = { sourceMaps: true }
  Object.assign(config, JSON.parse(read('.babelrc', 'utf8')))
  const compiled = babel(source, config)

  return { source: compiled.code, map: compiled.map }
}
import { render as stylus } from 'stylus'
b.componentify.compilers['text/stylus'] = function (source, file) {
  const config = { filename: file }
  const compiled = stylus(source, config)

  return { source: compiled }
}

import browserify from 'browserify'
const bundle = browserify(`${dir}/${entry}`, {
  debug: f.debug,
  cache: {},
  extensions: ['.js', '.ract'],
  paths: [dir]
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
    .pipe(source(entry))
    .pipe(buffer())
    .pipe(g.if(f.debug, g.sourcemaps.init({loadMaps: true})))
    .pipe(g.bytediff.start())
    .pipe(g.if(f.min, g.uglify({mangle: true, compress: {unsafe: true}})))
    .pipe(g.if(f.debug, g.sourcemaps.write()))
    .pipe(g.bytediff.stop())
    .pipe(gulp.dest(out))
}
export function watch_js () {
  return gulp.watch(`${dir}/**.js`, vinyl => {
    b.rememberify.forget(bundle, vinyl.path)
    return js()
  })
}
