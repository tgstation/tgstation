class @Handlers
  constructor: (@bus, @fragment = document) ->
    @bus.on "rendered", @updateStatus
    @bus.on "rendered", @updateLinks
    @bus.on "rendered", @handleLinks
    @bus.on "rendered", @handleClose
    @bus.on "rendered", @handleMini

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
      return
    return


  updateLinks: (data) =>
    links = @fragment.queryAll ".link"
    if data.config.status isnt NANO.INTERACTIVE
      links.forEach (element) ->
        element.className = "link disabled"
        return
    return


  handleLinks: (data) =>
    onClick = (event) ->
      action = @data "action"
      params = JSON.parse @data "params"

      if action? and params? and data.config.status is NANO.INTERACTIVE
        @classList.add "pending"
        nanoui.bycall action, params
      return

    @fragment.queryAll(".link.active").forEach (link) ->
      link.on "click", onClick
      return
    return

  handleClose: (data) ->
    onClick = (event) -> nanoui.close()

    closers = document.queryAll ".close"
    closers.forEach (closer) ->
      closer.on "click", onClick
      return
    return

  handleMini: (data) ->
    onClick = (event) -> nanoui.winset "is-minimized", "true"

    minimizers = document.queryAll ".minimize"
    minimizers.forEach (minimizer) ->
      minimizer.on "click", onClick
      return
    return
