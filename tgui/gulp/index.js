import gulp from 'gulp'

import build from './tasks/build'
import clean from './tasks/clean'
import reload from './tasks/reload'
import watch from './tasks/watch'

gulp.task(clean)
gulp.task('default', gulp.series(clean, build))
gulp.task('update', gulp.series(clean, build, reload))
gulp.task(watch)
