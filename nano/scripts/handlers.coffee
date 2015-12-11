class @Handlers
  constructor: (@bus, @fragment = document) ->
    @bus.on "rendered", @updateStatus
    @bus.on "rendered", @updateLinks
    @bus.on "rendered", @attachHandlers
    @bus.on "error",    @error

  updateStatus: (data) =>
    statusicons = @fragment.queryAll(".statusicon")
    statusicons.forEach (statusicon) ->
      statusicon.className = "statusicon fa fa-eye fa-2x"
      switch data.config.status
        when 2
          klass = "good"
        when 1
          klass = "average"
        else
          klass = "bad"
      statusicon.classList.add klass
      return
    return


  updateLinks: (data) =>
    links = @fragment.queryAll(".link")
    if data.config.status isnt 2
      links.forEach (element) ->
        element.className = "link disabled"
        return
    return


  attachHandlers: (data) =>
    onClick = (event) ->
      href = @data("href")
      if href? and data.config.status is 2
        @classList.add "pending"
        location.href = href
      return

    @fragment.queryAll(".link").forEach (element) ->
      element.on "click", onClick
      return
    return


  error: (message) ->
    url = util.href(nanoui_error: message)
    location.href = url
    return
