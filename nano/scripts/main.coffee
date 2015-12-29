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

# Load initial data from the server.
data = JSON.parse document.query("meta[name='data']").getAttribute "content"
if not data? or not (data.data? and data.config?)
  alert "Initial data did not load correctly."

# Create the NanoUI; this is just a Ractive component.
window.nanoui = new NanoUI
  el: "#container"
  data: data
  components: # Components used in building NanoUIs; interfaces depend on these.
    interface: interfaces[data.config.interface]
    "n-display": require "./components/display"
    "n-notice": require "./components/notice"
    "n-section": require "./components/section"
    "n-bar": require "./components/bar"
    "n-button": require "./components/button"
  onrender: ->
    document.body.className = @get "config.style"
