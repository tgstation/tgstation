require "ie8"
require "dom4"
require "es5-shim"
require "html5shiv"
require "./math"

Ractive = require "ractive"
WebFont = require "webfontloader"


# Set Ractive debug mode based on if we're minified or not.
Ractive.DEBUG = /minified/.test (minified) ->


# Load FontAwesome asynchronously from CDNJS.
WebFont.load
  custom:
    families: ["FontAwesome"]
    urls: ["https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css"]


# Load initial data from the server.
data = document.query "#data"
data = JSON.parse data.textContent
if not data? or not (data.data? and data.config?)
  alert "Initial data did not load correctly."


# Load the base component and all interfaces.
NanoUI     = require "./nanoui"
interfaces = require "./interfaces/*", mode: "hash"

# Pick the interface based on the config.
iface = interfaces[data.config.interface]
# Override the interface with a fallback if it does not exist.
iface = require "./interfaces/error" unless iface?


# Create the NanoUI; this is just a Ractive component.
window.nanoui = new NanoUI
  data: data
  el: "#container"
  components: # Components used in building NanoUIs; interfaces depend on these.
    interface: iface
    "n-display": require "./components/display"
    "n-notice": require "./components/notice"
    "n-section": require "./components/section"
    "n-bar": require "./components/bar"
    "n-button": require "./components/button"
  onrender: ->
    @observe "config.style", (newkey, oldkey, keypath) -> # Change body style to match config
      @el.classList.remove oldkey; @el.classList.add newkey
      document.body.classList.remove oldkey; document.body.classList.add newkey
