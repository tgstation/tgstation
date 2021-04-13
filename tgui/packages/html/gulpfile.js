const basename = process.platform === 'win32'
  ? require('path').win32.basename
  : require('path').basename;
const cleanCss = require('gulp-clean-css');
const gulp = require('gulp');
const pipeline = require('readable-stream').pipeline;
const rename = require('gulp-rename');
const terser = require('gulp-terser');

gulp.task('styles', function () {
  return pipeline(
    gulp.src([
      './src/**/!(*.min).css'
    ], { base: "." }),
    cleanCss(),
    rename(file => {
      return {
        dirname: basename(file.dirname),
        basename: file.basename,
        extname: '.min' + file.extname
      }
    }),
    gulp.dest('./dist/')
  );
});

gulp.task('scripts', function () {
  return pipeline(
    gulp.src([
      './src/**/!(*.min).js'
    ], { base: "." }),
    terser({
      compress: {
        dead_code: true,
        drop_console: true,
        drop_debugger: true,
        keep_classnames: true,
        keep_fargs: true,
        keep_fnames: true,
        keep_infinity: false,
        passes: 5
      },
      ie8: true,
      mangle: {
        eval: true,
        keep_classnames: true,
        keep_fnames: true,
        toplevel: true
      },
      module: false,
      output: {
        comments: 'some'
      },
      sourceMap: false
    }),
    rename(file => {
      return {
        dirname: basename(file.dirname),
        basename: file.basename,
        extname: '.min' + file.extname
      }
    }),
    gulp.dest('./dist/')
  );
});

gulp.task('default', gulp.series('scripts', 'styles'));
