module.exports =
  browserify:
    aliasify:     require "aliasify"
    babelify:     require "babelify"
    coffeeify:    require "coffeeify"
    componentify: require "ractive-componentify"
    es3ify:       require "es3ify"
    globify:      require "require-globify"
    helpers:      require "babelify-external-helpers"
  gulp: require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g})
  postcss:
    autoprefixer: require "autoprefixer"
    colorblind:   require "postcss-colorblind"
    fontweights:  require "postcss-font-weights"
    gradient:     require "postcss-filter-gradient"
    opacity:      require "postcss-opacity"
    plsfilters:   require "pleeease-filters"
    rgba:         require "postcss-color-rgba-fallback"
