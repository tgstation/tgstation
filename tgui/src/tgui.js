// Temporarily import Ractive first to keep it from detecting ie8's object.defineProperty shim, which it misuses (ractivejs/ractive#2343).
import Ractive from 'ractive'
Ractive.DEBUG = /minified/.test(() => {/* minified */})

import 'ie8'
import 'babel-polyfill'
import 'dom4'
import 'html5shiv'

Object.assign(Math, require('util/math'))

import WebFont from 'webfontloader'
WebFont.load({
  custom: {
    families: [ 'FontAwesome' ],
    urls: [ 'https://netdna.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css' ],
    testStrings: { FontAwesome: '\uf240' }
  }
})

import TGUI from 'tgui.ract'
window.initialize = (dataString) => {
  if (window.tgui) return
  window.tgui = new TGUI({
    el: '#container',
    data () {
      const initial = JSON.parse(dataString)
      return {
        constants: require('util/constants'),
        config: initial.config,
        data: initial.data,
        adata: initial.data
      }
    }
  })
  window.initialize = function () {}
}

const holder = document.getElementById('data')
const data = holder.textContent
const ref = holder.getAttribute('data-ref')
if (data !== '{}') { // If the JSON was inlined, load it.
  window.initialize(data)
  holder.remove()
}

import { act } from 'util/byond'
act(ref, 'tgui:initialize')
