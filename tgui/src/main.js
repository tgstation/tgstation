// Temporarily import Ractive first to keep it from detecting ie8's object.defineProperty shim, which it misuses (ractivejs/ractive#2343).
import Ractive from 'ractive'
Ractive.DEBUG = /minified/.test(() => {
  /* minified */
})

import 'ie8'
import 'babel-polyfill'
import 'dom4'
import 'html5shiv'

Object.assign(Math, require('./math'))

import WebFont from 'webfontloader'
WebFont.load({
  custom: {
    families: [
      'FontAwesome'
    ],
    urls: [
      'https://netdna.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css'
    ],
    testStrings: {
      FontAwesome: '\uf240'
    }
  }
})

import TGUI from './tgui'
window.initialize = (dataString) => {
  if (window.tgui) return
  window.tgui = new TGUI({
    el: '#container',
    data: () => JSON.parse(dataString)
  })
}

import { act } from './byond'
const holder = document.getElementById('data')
if (holder.textContent !== '{}') { // If the JSON was inlined, load it.
  window.initialize(holder.textContent)
} else {
  act(holder.getAttribute('data-ref'), 'tgui:initialize')
  holder.remove()
}
