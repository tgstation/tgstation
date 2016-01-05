require "ie8"
require "dom4"
require "es5-shim"
require "html5shiv"
require "./math"


Ractive = require "ractive"
Ractive.DEBUG = /minified/.test (minified) -> # Set Ractive debug mode based on if we're minified or not.

WebFont = require "webfontloader"
WebFont.load # Load FontAwesome asynchronously from CDNJS.
  custom:
    families: ["FontAwesome"]
    urls: ["https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css"]
    testStrings:
      FontAwesome: "\uf240"

tgui = require "./tgui.ract"
window.initialize = (dataString) -> # So we can get data inline or from the server.
  return if window.tgui # Just incase we get called again; only do this once.
  window.tgui = new tgui # Create the UI; this is just a Ractive component.
    el: "#container" # Attach the UI to the existing container div.
    data: -> data = JSON.parse dataString # Load initial data from the server.

holder = document.getElementById "data"
if holder.textContent != "{}" # If the JSON was inlined, load it.
  window.initialize(holder.textContent)
else
  byond = require "./byond"
  byond.act holder.getAttribute("data-ref"), "tgui:initialize"
  holder.remove()
