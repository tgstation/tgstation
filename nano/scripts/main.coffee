document.when "ready", =>
  coderbus = {}

  @nanoui = new @NanoUI coderbus, document
  @handlers = new @Handlers coderbus, document
  @helpers = new @Helpers coderbus, document
  @util = new @Util coderbus, document

  coderbus.emit "memes"

  @NanoBus = coderbus
  return
