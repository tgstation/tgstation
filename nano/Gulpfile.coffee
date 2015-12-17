### Settings ###
util = require("gulp-util")
s =
  min: util.env.min
  colorblind: util.env.colorblind

# Project Paths
input =
  fonts:     "**/*.{eot,woff2}"
  images:    "images"
  scripts:   "scripts"
  styles:    "styles"
  templates: "templates"

output =
  dir: "assets"
  scripts:
    lib: "nanoui.lib.js"
    main: "nanoui.main.js"
  styles:
    lib: "nanoui.lib.css"
    prefix: "nanoui."
  templates: "nanoui.templates.js"

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

### Pacakages ###
bower         = require "main-bower-files"
child_process = require "child_process"
del           = require "del"
gulp          = require "gulp"
merge         = require "merge-stream"

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
gulp.task "default", ["fonts", "scripts", "styles", "templates"]

gulp.task "clean", ->
  del glob output.dir

gulp.task "watch", ->
  gulp.watch [glob input.images], ["reload"]
  gulp.watch [glob input.scripts], ["reload"]
  gulp.watch [glob input.styles], ["reload"]
  gulp.watch [glob input.templates], ["reload"]

gulp.task "reload", ["default"], ->
  child_process.exec "reload.bat", (err, stdout, stderr) ->
    return console.log err if err

gulp.task "fonts", ["clean"], ->
  gulp.src bower input.fonts
    .pipe gulp.dest output.dir

gulp.task "scripts", ["clean"], ->
  lib = gulp.src bower "**/*.js"
    .pipe g.concat(output.scripts.lib)
    .pipe g.if(s.min, g.uglify(), g.jsbeautifier())
    .pipe gulp.dest output.dir

  main = gulp.src glob input.scripts
    .pipe g.coffee()
    .pipe g.concat(output.scripts.main)
    .pipe g.if(s.min, g.uglify(), g.jsbeautifier())
    .pipe gulp.dest output.dir

  merge lib, main

gulp.task "styles", ["clean"], ->
  lib = gulp.src bower "**/*.css"
    .pipe g.replace("../fonts/", "")
    .pipe g.concat(output.styles.lib)
    .pipe g.if(s.min, g.cssnano({discardComments: {removeAll: true}}), g.csscomb())
    .pipe gulp.dest output.dir

  main = gulp.src glob input.styles
    .pipe g.filter(["*.less", "!_*.less"])
    .pipe g.less({paths: [input.images]})
    .pipe g.postcss([
      p.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
      p.plsfilters({oldIE: true}),
      p.rgba({oldie: true}),
      p.opacity,
      p.gradient,
      p.fontweights
    ])
    .pipe g.if(s.colorblind, g.postcss([p.colorblind]))
    .pipe g.if(s.min, g.cssnano({discardComments: {removeAll: true}}), g.csscomb())
    .pipe g.rename({prefix: output.styles.prefix})
    .pipe gulp.dest output.dir

  merge lib, main

gulp.task "templates", ["clean"], ->
  gulp.src glob input.templates
    .pipe g.dotprecompiler({dictionary: "TMPL", templateSettings: dotOpts})
    .pipe g.concat(output.templates)
    .pipe g.header("window.TMPL = {};\n")
    .pipe g.if(s.min, g.uglify(), g.jsbeautifier())
    .pipe gulp.dest output.dir
