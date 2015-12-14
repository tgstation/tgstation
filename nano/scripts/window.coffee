class @Window
  constructor: (@bus, @fragment = document) ->
    @dragging = false
    @resizing = false

    @bus.on "initialized", (data) =>
      return unless data.config.user.fancy
      @fancyChrome()
      @calcOffset()
      @attachButtons()
      @attachDrag()
      @attachResize()

  setPos: (x, y) ->
    nanoui.winset "pos", "#{x},#{y}"

  setSize: (w, h) ->
    nanoui.winset "size", "#{w},#{h}"

  fancyChrome: =>
    nanoui.winset "titlebar", 0
    nanoui.winset "can-resize", 0
    fancy = @fragment.queryAll ".fancy"
    fancy.forEach (element) ->
      element.style.display = 'inherit'

  calcOffset: =>
    @xOriginal = window.screenLeft
    @yOriginal = window.screenTop
    @setPos 0, 0 # Move to 0,0 to measure offsets.
    @xOffset = window.screenLeft
    @yOffset = window.screenTop
    @setPos @xOriginal - @xOffset, @yOriginal - @yOffset # Put the window back.

  attachButtons: =>
    close = -> nanoui.close()
    minimize = -> nanoui.winset "is-minimized", "true"

    closers = @fragment.queryAll ".close"
    closers.forEach (closer) ->
      closer.on "click", close
    minimizers = @fragment.queryAll ".minimize"
    minimizers.forEach (minimizer) ->
      minimizer.on "click", minimize

  attachDrag: =>
    titlebar = @fragment.query "#titlebar"
    @fragment.on "mousemove", @drag
    titlebar.on "mousedown", => @dragging = true
    @fragment.on "mouseup", => @dragging = false

  drag: (event = window.event) =>
    return unless @dragging

    @xDrag = event.screenX unless @xDrag?
    @yDrag = event.screenY unless @yDrag?

    x = (event.screenX - @xDrag) + (window.screenLeft - @xOffset)
    y = (event.screenY - @yDrag) + (window.screenTop - @yOffset)
    @setPos x, y

    @xDrag = event.screenX
    @yDrag = event.screenY

  attachResize: =>
    handle = @fragment.query "#resize"
    @fragment.on "mousemove", @resize
    handle.on "mousedown", => @resizing = true
    @fragment.on "mouseup", => @resizing = false

  resize: (event = window.event) =>
    return unless @resizing

    @xResize = event.screenX unless @xResize?
    @yResize = event.screenY unless @yResize?

    x = (event.screenX - @xResize) + window.innerWidth
    y = (event.screenY - @yResize) + window.innerHeight
    @setSize x, y

    @xResize = event.screenX
    @yResize = event.screenY
