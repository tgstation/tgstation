// Temporarily import Ractive first to keep it from detecting ie8's object.defineProperty shim, which it misuses (ractivejs/ractive#2343).
import Ractive from 'ractive'
Ractive.DEBUG = /minified/.test(() => {/* minified */})

import 'ie8'
import 'babel-polyfill'
import 'dom4'
import 'html5shiv'

// Extend the Math builtin with our own utilities.
Object.assign(Math, require('util/math'))

// Set up the initialize function. This is either called below if JSON is provided
// inline, or called by the server if it was not.
import TGUI from 'tgui.ract'
window.initialize = (dataString) => {
  if (window.tgui) return // Don't run twice.
  window.tgui = new TGUI({
    el: '#container',
    data () {
      const initial = JSON.parse(dataString)
      return {
        constants: require('util/constants'),
        text: require('util/text'),
        config: initial.config,
        data: initial.data,
        adata: initial.data
      }
    }
  })
}

// Try to find data in the page. If the JSON was inlined, load it.
const holder = document.getElementById('data')
const data = holder.textContent
const ref = holder.getAttribute('data-ref')
if (data !== '{}') {
  window.initialize(data)
  holder.remove()
}
// Let the server know we're set up. This also sends data if it was not inlined.
import { act } from 'util/byond'
act(ref, 'tgui:initialize')

// Load fonts.
import { loadCSS } from 'fg-loadcss'
loadCSS('https://cdn.jsdelivr.net/fontawesome/4.5.0/css/font-awesome.min.css')
// Handle font loads.
import FontFaceObserver from 'fontfaceobserver'
const fontawesome = new FontFaceObserver('FontAwesome')
fontawesome.check('\uf240')
  .then(() => document.body.classList.add('icons'))
  .catch(() => document.body.classList.add('no-icons'))
