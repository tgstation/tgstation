import * as f from '../flags'
import { gulp as g, postcss as s } from '../plugins'

const dir = 'generated'
const entry = 'tgui.styl'
const out = 'assets'

import gulp from 'gulp'
export function css () {
  return gulp.src(`${dir}/${entry}`)
    .pipe(g.if(f.debug, g.sourcemaps.init({loadMaps: true})))
    .pipe(g.stylus({ url: 'data-url', paths: ['images/'] }))
    .pipe(g.postcss([
      s.autoprefixer({ browsers: ['last 2 versions', 'ie >= 9'] }),
      s.gradient,
      s.opacity,
      s.rgba({oldie: true}),
      s.plsfilters({oldIE: true}),
      s.fontweights
    ]))
    .pipe(g.bytediff.start())
    .pipe(g.if(f.min, g.minifycss()))
    .pipe(g.if(f.min, g.csso()))
    .pipe(g.if(f.min, g.cssnano()))
    .pipe(g.if(f.debug, g.sourcemaps.write()))
    .pipe(g.bytediff.stop())
    .pipe(gulp.dest(out))
}
export function watch_css () {
  return gulp.watch(`${dir}/**.styl`, css)
}
