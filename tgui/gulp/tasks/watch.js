import * as p from '../paths'

import build from './build'
import clean from './clean'
import reload from './reload'

import debounce from 'debounce'
import gulp from 'gulp'
module.exports = function () {
  return gulp.watch(
    Object.keys(p).filter((path) => p[path].dir).map((path) => p[path].dir + '**'),
    debounce(gulp.series(clean, build, reload), 1000)
  )
}
module.exports.displayName = 'watch'
