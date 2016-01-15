import gulp from 'gulp'

import { css, watch_css } from './tasks/css'
import { js, watch_js } from './tasks/js'
import { reload, watch_reload } from './tasks/reload'
import { size } from './tasks/size'

gulp.task(reload)
gulp.task(size)

gulp.task('default', gulp.series(gulp.parallel(css, js), size))
gulp.task('watch', gulp.parallel(watch_css, watch_js, watch_reload))
