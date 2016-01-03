gutil = require "gulp-util"


module.exports =
  colorblind: gutil.env.colorblind || gutil.env.c
  debug: gutil.env.debug || gutil.env.d
  min: gutil.env.min || gutil.env.m
