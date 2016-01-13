import * as p from '../paths'

import { exec } from 'child_process'
export function reload () {
  return exec('reload.bat')
}
import gulp from 'gulp'
export function watch_reload () {
  return gulp.watch(p.out + '**', reload)
}
