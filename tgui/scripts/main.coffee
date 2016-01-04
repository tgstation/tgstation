require "ie8"
require "dom4"
require "es5-shim"
require "html5shiv"
require "./math"


Ractive = require "ractive"
# Set Ractive debug mode based on if we're minified or not.
Ractive.DEBUG = /minified/.test (minified) ->

WebFont = require "webfontloader"
# Load FontAwesome asynchronously from CDNJS.
WebFont.load
  custom:
    families: ["FontAwesome"]
    urls: ["https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css"]
    testStrings:
      FontAwesome: "\uf240"

window.initialize = (dataString) ->
  tgui = require "./tgui"
  # Create the UI; this is just a Ractive component.
  window.tgui = new tgui
    el: "#container"
    data: ->
      data = JSON.parse dataString # Load initial data from the server.
      data.adata = data.data # Spoof animated data as this is the first load.
      data

holder = document.getElementById "data"
if holder.textContent != "{}"
  window.initialize(holder.textContent)
  holder.remove()
  window.initialize = (_) ->
