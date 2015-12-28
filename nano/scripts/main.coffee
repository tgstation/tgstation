require "ie8"
require "dom4"
require "es5-shim"
require "html5shiv"

Ractive = require "ractive"
Test = require "components/test.ract"

window.nanoui = new Test
  el: "#layout",
  data:
    name: "world"
