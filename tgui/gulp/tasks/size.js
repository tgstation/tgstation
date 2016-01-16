import * as p from '../paths'
import { gulp as g } from '../plugins'

import gulp from 'gulp'
export function size () {
  return gulp.src(p.out + '*')
    .pipe(g.size())
}
