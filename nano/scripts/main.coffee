# Polyfills; these are wired globally.
require "ie8"
require "dom4"
require "es5-shim"
require "html5shiv"

# Extensions; also wired globally.
require "./math"

# NanoUI and its interfaces.
NanoUI     = require "./nanoui"
interfaces = require "./interfaces/*", mode: "hash"

# Get WebFonts loading.
WebFont = require "webfontloader"
WebFont.load
  custom:
    families: ["FontAwesome"]
    urls: ["https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.5.0/css/font-awesome.min.css"]

# Load initial data from the server.
data = document.query "#data"
data = JSON.parse data.textContent
if not data? or not (data.data? and data.config?)
  alert "Initial data did not load correctly."

# Check that the UI exists, and switch to an "error" interface if it does not.
ui = interfaces[data.config.interface]
ui = interfaces.error unless ui?

# Create the NanoUI; this is just a Ractive component.
window.nanoui = new NanoUI
  el: "#container"
  data: data
  components: # Components used in building NanoUIs; interfaces depend on these.
    interface: ui
    "n-display": require "./components/display"
    "n-notice": require "./components/notice"
    "n-section": require "./components/section"
    "n-bar": require "./components/bar"
    "n-button": require "./components/button"
  onrender: ->
    document.body.classList.add @get "config.style"
