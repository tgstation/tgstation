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

NanoUI = require "./nanoui"
# Create the NanoUI; this is just a Ractive component.
window.nanoui = new NanoUI
  el: "#container"
  data: ->
    data = JSON.parse document.getElementById("data").textContent # Load initial data from the server.
    alert "Initial data did not load correctly." if not data? or not (data.data? and data.config?)
    data.adata = data.data # Spoof animated data as this is the first load.
    data
  onrender: ->
    @observe "config.style", (newkey, oldkey, keypath) -> # Change body style to match config.
      document.body.classList.remove oldkey if oldkey?
      document.body.classList.add newkey if newkey?
