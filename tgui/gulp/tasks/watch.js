import * as p from '../paths'

import { watch_css } from './css'
import { watch_js } from './js'

import gulp from 'gulp'
module.exports = gulp.parallel(watch_css, watch_js)
module.exports.displayName = 'watch'
