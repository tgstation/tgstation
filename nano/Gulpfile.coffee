### Settings ###
util = require("gulp-util")
f =
  colorblind: util.env.colorblind || util.env.c
  min: util.env.min || util.env.m
  sourcemaps: util.env.sourcemaps || util.env.s

# Project Paths
input =
  html:      "html"
  images:    "images"
  scripts:   "scripts"
  styles:    "styles"
  templates: "templates"

output =
  dir: "assets"
  js: "nanoui.js"
  css: "nanoui.css"

# doT Settings
dotOpts =
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

### Packages ###
bower         = require "main-bower-files"
child_process = require "child_process"
del           = require "del"
gulp          = require "gulp"
merge         = require "merge2"

### Plugins ###
g = require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g})
p =
  autoprefixer: require "autoprefixer"
  colorblind:   require "postcss-colorblind"
  fontweights:  require "postcss-font-weights"
  gradient:     require "postcss-filter-gradient"
  opacity:      require "postcss-opacity"
  plsfilters:   require "pleeease-filters"
  rgba:         require "postcss-color-rgba-fallback"

### Helpers ###

glob = (path) ->
  "#{path}/*"

### Tasks ###
html = ->
  gulp.src glob input.html
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.htmlmin({collapseWhitespace: true, minifyJS: true, minifyCSS: true, quoteCharacter: "'"}))
    .pipe g.bytediff.stop()
    .pipe gulp.dest output.dir


js = ->
  lib = gulp.src bower "**/*.js"
    .pipe g.if(f.sourcemaps, g.sourcemaps.init())

  main = gulp.src glob input.scripts
    .pipe g.if(f.sourcemaps, g.sourcemaps.init())
    .pipe g.coffee()

  templates = gulp.src glob input.templates
    .pipe g.dotprecompiler({dictionary: "TMPL", templateSettings: dotOpts})
    .pipe g.concat("templates")
    .pipe g.header("window.TMPL = {};\n")

  combined = merge lib, templates, main
  combined
    .pipe g.concat(output.js)
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.uglify(), g.jsbeautifier())
    .pipe g.if(f.sourcemaps, g.sourcemaps.write())
    .pipe g.bytediff.stop()
    .pipe gulp.dest output.dir


css = ->
  lib = gulp.src bower "**/*.css"
    .pipe g.if(f.sourcemaps, g.sourcemaps.init())

  main = gulp.src glob input.styles
    .pipe g.filter(["*.less", "!_*.less"])
    .pipe g.if(f.sourcemaps, g.sourcemaps.init())
    .pipe g.less({paths: [input.images]})
    .pipe g.postcss([
      p.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
      p.plsfilters({oldIE: true}),
      p.rgba({oldie: true}),
      p.opacity,
      p.gradient,
      p.fontweights
    ])
    .pipe g.if(f.colorblind, g.postcss([p.colorblind]))

  combined = merge lib, main
  combined
    .pipe g.concat(output.css)
    .pipe g.bytediff.start()
    .pipe g.if(f.min, g.cssnano({discardComments: {removeAll: true}}), g.csscomb())
    .pipe g.if(f.sourcemaps, g.sourcemaps.write())
    .pipe g.bytediff.stop()
    .pipe gulp.dest output.dir


gulp.task "default", ["clean"], ->
  all = merge js(), css(), html()
  all.pipe g.size()

gulp.task "reload", ["default"], ->
  child_process.exec "reload.bat", (err, stdout, stderr) ->
    console.log err if err

gulp.task "watch", ->
  Object.keys(input).forEach (inp) ->
    gulp.watch [glob input[inp]], ["reload"]

gulp.task "clean", -> del glob output.dir
