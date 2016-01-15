const out = 'assets'

import { exec } from 'child_process'
export function reload () {
  return exec('reload.bat')
}
import gulp from 'gulp'
export function watch_reload () {
  return gulp.watch(`${out}/**`, reload)
}
