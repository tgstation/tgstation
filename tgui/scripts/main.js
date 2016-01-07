import 'babel-polyfill'
import 'dom4'


Object.assign(Math, require('./math'))

import Ractive from 'ractive'
Ractive.DEBUG = /minified/.test(() => {
  /* minified */
})

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
let holder = document.getElementById('data')
if (holder.textContent !== '{}') { // If the JSON was inlined, load it.
  window.initialize(holder.textContent)
} else {
  act(holder.getAttribute('data-ref'), 'tgui:initialize')
  holder.remove()
}
