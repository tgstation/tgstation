util = require "gulp-util"
module.exports =
  colorblind: util.env.colorblind || util.env.c
  min: util.env.min || util.env.m
  debug: util.env.debug || util.env.d
