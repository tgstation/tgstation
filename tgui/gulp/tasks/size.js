import * as p from '../paths'
import { gulp as g } from '../plugins'

import gulp from 'gulp'
module.exports = function () {
  return gulp.src(`${p.out}/*`)
    .pipe(g.size())
}
module.exports.displayName = 'size'
