import { css } from './css'
import { js } from './js'
import size from './size'

import gulp from 'gulp'
module.exports = gulp.series(gulp.parallel(css, js), size)
module.exports.displayName = 'build'
