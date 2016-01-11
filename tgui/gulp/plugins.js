export const browserify = {
  babelify: require('babelify'),
  collapse: require('bundle-collapser/plugin'),
  componentify: require('ractive-componentify'),
  globify: require('require-globify'),
  helpers: require('babelify-external-helpers'),
  rememberify: require('rememberify')
}

export const gulp = require('gulp-load-plugins')({replaceString: /^gulp(-|\.)|-/g})

export const postcss = {
  autoprefixer: require('autoprefixer'),
  fontweights: require('postcss-font-weights'),
  plsfilters: require('pleeease-filters')
}
