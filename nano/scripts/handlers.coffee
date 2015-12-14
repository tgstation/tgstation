class @Handlers
  constructor: (@bus, @fragment = document) ->
    @bus.on "rendered", @updateStatus
    @bus.on "rendered", @updateLinks
    @bus.on "rendered", @handleLinks

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

  handleLinks: (data) =>
    onClick = (event) ->
      action = @data "action"
      params = JSON.parse @data "params"

      if action? and params? and data.config.status is NANO.INTERACTIVE
        nanoui.bycall action, params

    @fragment.queryAll(".link.active").forEach (link) ->
      link.on "click", onClick
