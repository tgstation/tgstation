class @Window
  constructor: (@bus, @fragment = document) ->
    @dragging = false
    @resizing = false

    @bus.once "initialized", (data) =>
      setTimeout @focusMap, 100 # Return focus once we're set up.
      return unless data.config.user.fancy # Bail here if we're not to go chromeless.
      @fancyChrome()
      @calcOffset()
      @attachButtons()
      @attachDrag()
      @attachResize()

    @bus.on "rendered", @updateStatus
    @bus.on "rendered", @updateLinks
    @bus.on "rendered", @attachLinks
    @fragment.on "keydown", @focusMap # If we get input, return focus.

  setPos: (x, y) ->
    nanoui.winset "pos", "#{x},#{y}"

  setSize: (w, h) ->
    nanoui.winset "size", "#{w},#{h}"

  focusMap: ->
    nanoui.winset "focus", 1, "mapwindow.map"

  fancyChrome: =>
    nanoui.winset "titlebar", 0
    nanoui.winset "can-resize", 0
    fancy = @fragment.queryAll ".fancy"
    fancy.forEach (chrome) ->
      chrome.classList.remove "fancy"

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

    x = Math.max(250, (event.screenX - @xResize) + window.innerWidth)
    y = Math.max(250, (event.screenY - @yResize) + window.innerHeight)
    @setSize x, y

    @xResize = event.screenX
    @yResize = event.screenY

  updateStatus: (data) =>
    statusicons = @fragment.queryAll ".statusicon"
    statusicons.forEach (statusicon) ->
      statusicon.className = statusicon.className.replace /good|bad|average/g, ""
      switch data.config.status
        when NANO.INTERACTIVE
          klass = "good"
        when NANO.UPDATE
          klass = "average"
        else
          klass = "bad"
      statusicon.classList.add klass

  updateLinks: (data) =>
    links = @fragment.queryAll ".link"
    if data.config.status isnt NANO.INTERACTIVE
      links.forEach (element) ->
        element.className = "link disabled"

  attachLinks: (data) =>
    onClick = ->
      action = @data "action"
      params = JSON.parse @data "params"
      if action? and params? and data.config.status is NANO.INTERACTIVE
        nanoui.act action, params

    @fragment.queryAll(".link.active").forEach (link) ->
      link.on "click", onClick
