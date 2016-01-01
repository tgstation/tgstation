child_process = require "child_process"
gulp          = require "gulp"


module.exports = ->
  child_process.exec "reload.bat", (err, stdout, stderr) ->
    console.log err if err
module.exports.displayName = "reload"
