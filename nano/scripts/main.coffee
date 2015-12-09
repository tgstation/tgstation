document.when "ready", =>
  coderbus = {}

  nanoui = new @NanoUI coderbus
  handlers = new @Handlers coderbus
  coderbus.emit "memes"

  @NanoBus = coderbus
  return
