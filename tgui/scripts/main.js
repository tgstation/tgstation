import 'core-js'
import 'html5shiv'
import 'ie8'
import 'dom4'

import * as mathext from './math'
Object.assign(Math, mathext)

import Ractive from 'ractive'
Ractive.DEBUG = /minified/.test(() => {
  /*minified*/
})

import WebFont from 'webfontloader'
WebFont.load({
  custom: {
    families: [
      'FontAwesome'
    ],
    urls: [
      'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css'
    ],
    testStrings: {
      FontAwesome: '\uf240'
    }
  }
})

import tgui from './tgui'
window.initialize = (dataString) => {
  if (window.tgui) return
  window.tgui = new tgui({
    el: '#container',
    data: () => JSON.parse(dataString)
  })
}

import act from './byond'
let holder = document.getElementById('data')
if (holder.textContent != '{}') { // If the JSON was inlined, load it.
  window.initialize(holder.textContent)
} else {
  act(holder.getAttribute('data-ref'), 'tgui:initialize')
  holder.remove()
}
