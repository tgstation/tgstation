flags = require("minimist")(process.argv.slice(2))


module.exports =
  colorblind: flags.colorblind || flags.c
  debug: flags.debug || flags.d
  min: flags.min || flags.m
