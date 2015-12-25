class @Chrome
  constructor: (@nanoui, data) ->
    @nanoui.updated.add @windowStatus

    return unless data.config.user.fancy
    @dragging = false
    @resizing = false

    @switchChrome()
    @calcOffsets()
    @handleButtons()
    @handleDrag()
    @handleResize()

  windowStatus: (data) ->
    statusicons = document.queryAll ".statusicon"
    statusicons.forEach (statusicon) ->
      switch data.config.status
        when NANO.INTERACTIVE
          klass = "good"
        when NANO.UPDATE
          klass = "average"
        else
          klass = "bad"
      statusicon.classList.remove "good", "bad", "average"
      statusicon.classList.add klass

  switchChrome: ->
    @nanoui.winset "titlebar", 0
    @nanoui.winset "can-resize", 0
    fancy = document.queryAll ".fancy"
    fancy.forEach (chrome) ->
      chrome.classList.remove "fancy"

  calcOffsets: =>
    @xOriginal = window.screenLeft
    @yOriginal = window.screenTop
    @nanoui.setPos 0, 0 # Move to 0,0 to measure offsets.
    @xOffset = window.screenLeft
    @yOffset = window.screenTop
    @nanoui.setPos @xOriginal - @xOffset, @yOriginal - @yOffset # Put the window back.

  handleButtons: ->
    closers = document.queryAll ".close"
    closers.forEach (closer) ->
      closer.addEventListener "click", => @nanoui.close()

    minimizers = document.queryAll ".minimize"
    minimizers.forEach (minimizer) ->
      minimizer.addEventListener "click", => @nanoui.minimize()

  handleDrag: =>
    drag = (event = window.event) =>
      return unless @dragging

      @xDrag = event.screenX unless @xDrag?
      @yDrag = event.screenY unless @yDrag?

      x = (event.screenX - @xDrag) + (window.screenLeft - @xOffset)
      y = (event.screenY - @yDrag) + (window.screenTop - @yOffset)
      @nanoui.setPos x, y

      @xDrag = event.screenX
      @yDrag = event.screenY

    titlebar = document.query "#titlebar"
    document.addEventListener "mousemove", drag
    titlebar.addEventListener "mousedown", => @dragging = true
    document.addEventListener "mouseup", => @dragging = false; delete @xDrag; delete @yDrag

  handleResize: =>
    resize = (event = window.event) =>
      return unless @resizing

      @xResize = event.screenX unless @xResize?
      @yResize = event.screenY unless @yResize?

      x = Math.max 250, (event.screenX - @xResize) + window.innerWidth
      y = Math.max 250, (event.screenY - @yResize) + window.innerHeight
      @nanoui.setSize x, y

      @xResize = event.screenX
      @yResize = event.screenY

    handle = document.query "#resize"
    document.addEventListener "mousemove", resize
    handle.addEventListener "mousedown", => @resizing = true
    document.addEventListener "mouseup", => @resizing = false; delete @xResize; delete @yResize
