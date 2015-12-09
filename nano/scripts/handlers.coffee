class @Handlers
  constructor: (@bus) ->
    @bus.on "rendered", @updateStatus
    @bus.on "rendered", @updateLinks
    @bus.on "rendered", @attachHandlers
    @bus.on "error",    @error

  updateStatus: (data) ->
    statusicons = document.queryAll(".statusicon")
    statusicons.forEach (statusicon) ->
      switch data.config.status
        when 2
          statusicon.className = "statusicon good"
        when 1
          statusicon.className = "statusicon average"
        else
          statusicon.className = "statusicon bad"
      return
    return


  updateLinks: (data) ->
    links = document.queryAll(".link")
    if data.config.status isnt 2
      links.forEach (element) ->
        element.className = "link disabled"
        return
    return


  attachHandlers: (data) ->
    onClick = (event) ->
      href = @data("href")
      if href? and data.config.status is 2
        @classList.add "pending"
        location.href = href
      return

    document.queryAll(".link").forEach (element) ->
      element.on "click", onClick
      return
    return


  error: (message) ->
    url = Util.href(nanoui_error: message)
    location.href = url
    return
