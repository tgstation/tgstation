document.when "ready", =>
  coderbus = {}

  @nanoui = new @NanoUI coderbus, document
  @nanowindow = new @Window coderbus, document

  coderbus.emit "memes"

  @NanoBus = coderbus
  return
