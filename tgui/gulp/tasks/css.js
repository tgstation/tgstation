import * as f from '../flags'
import * as p from '../paths'
import { gulp as g, postcss as s } from '../plugins'

import gulp from 'gulp'
module.exports = function () {
  return gulp.src(p.css.dir + p.css.main)
    .pipe(g.if(f.debug, g.sourcemaps.init({loadMaps: true})))
    .pipe(g.stylus({ url: 'data-url', paths: [p.img.dir] }))
    .pipe(g.postcss([
      s.autoprefixer({ browsers: ['last 2 versions', 'ie >= 9'] }),
      s.plsfilters,
      s.fontweights
    ]))
    .pipe(g.rename(p.css.out))
    .pipe(g.bytediff.start())
    .pipe(g.if(f.min, g.cssnano({ autoprefixer: { browsers: ['last 2 versions', 'ie >= 9'] }, discardComments: { removeAll: true } })))
    .pipe(g.if(f.debug, g.sourcemaps.write({ sourceRoot: '/source/#{p.css.dir}' })))
    .pipe(g.bytediff.stop())
    .pipe(gulp.dest(p.out))
}
module.exports.displayName = 'css'
