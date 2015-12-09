### Settings ###
min = require("gulp-util").env.min

# Project Paths
paths =
  scripts: ["scripts/*.coffee"]
  styles:  ["styles/*.less"]
  templates: ["templates/*.dot"]
  build: "assets"

# doT Settings
dotSettings =
  evaluate:      /\{\{([\s\S]+?)\}\}/g,
  interpolate:   /\{\{=([\s\S]+?)\}\}/g,
  encode:        /\{\{!([\s\S]+?)\}\}/g,
  use:           /\{\{#([\s\S]+?)\}\}/g,
  define:        /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g,
  conditional:   /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g,
  iterate:       /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
  varname:       "data, config, helper",
  strip:         true,
  append:        true,
  selfcontained: true

# CSSNano Settings
nanoOpts =
  discardComments:
    removeAll: true


### Gulp ###
gulp       = require "gulp"
gulpif     = require "gulp-if"
jsbeautify = require "gulp-jsbeautifier"
bower      = require "main-bower-files"
coffee     = require "gulp-coffee"
concat     = require "gulp-concat"
csscomb    = require "gulp-csscomb"
del        = require "del"
dot        = require "gulp-dot-precompiler"
header     = require "gulp-header"
filter     = require "gulp-filter"
gutil      = require "gulp-util"
less       = require "gulp-less"
merge      = require "merge-stream"
postcss    = require "gulp-postcss"
replace    = require "gulp-replace"
uglify     = require "gulp-uglify"

### PostCSS ###

autoprefixer = require "autoprefixer"
clearfix     = require "postcss-clearfix"
cssnano      = require "cssnano"
url          = require "postcss-url"


### Tasks ###
gulp.task "default", ["fonts", "scripts", "styles", "templates"]

gulp.task "clean", ->
  del "#{paths.build}/*"

gulp.task "watch", ->
  gulp.watch paths.scripts, ["scripts"]
  gulp.watch paths.styles, ["styles"]
  gulp.watch paths.templates, ["templates"]

gulp.task "fonts", ->
  gulp.src bower "**/*.{eot,woff{,2}}"
    .pipe gulp.dest paths.build

gulp.task "scripts", ->
  lib = gulp.src bower "**/*.js"
    .pipe concat("lib.js")
    .pipe gulpif(min, uglify(), jsbeautify())
    .pipe gulp.dest paths.build

  nanoui = gulp.src paths.scripts
    .pipe coffee()
    .pipe concat("app.js")
    .pipe gulpif(min, uglify(), jsbeautify())
    .pipe gulp.dest paths.build

  merge lib, nanoui

gulp.task "styles", ->
  lib = gulp.src bower "**/*.css"
    .pipe replace("../fonts/", "")
    .pipe concat("lib.css")
    .pipe gulpif(min, postcss([cssnano(nanoOpts)]), csscomb())
    .pipe gulp.dest paths.build

  nanoui = gulp.src paths.styles
    .pipe filter(["*.less", "!_*.less"])
    .pipe less()
    .pipe postcss([
      url({url: "inline" }),
      autoprefixer({ browsers: ["last 2 versions", "> 5%", "ie <= 8"] }),
      clearfix
    ])
    .pipe gulpif(min, postcss([cssnano(nanoOpts)]), csscomb())
    .pipe gulp.dest paths.build

  merge lib, nanoui

gulp.task "templates", ->
  gulp.src paths.templates
    .pipe dot({dictionary: "TMPL", templateSettings: dotSettings})
    .pipe concat("templates.js")
    .pipe header("window.TMPL = {};\n")
  .pipe gulp.dest paths.build
