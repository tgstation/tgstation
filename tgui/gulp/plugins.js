export const browserify = {
  babelify: require('babelify'),
  collapse: require('bundle-collapser/plugin'),
  componentify: require('ractive-componentify'),
  es3ify: require('es3ify'),
  globify: require('require-globify'),
  helpers: require('babelify-external-helpers'),
  rememberify: require('rememberify')
}

export const gulp = require('gulp-load-plugins')({ replaceString: /^gulp(-|\.)|-/g })

export const postcss = {
  autoprefixer: require('autoprefixer'),
  fontweights: require('postcss-font-weights'),
  gradient: require('postcss-filter-gradient'),
  opacity: require('postcss-opacity'),
  plsfilters: require('pleeease-filters'),
  rgba: require('postcss-color-rgba-fallback')
}
