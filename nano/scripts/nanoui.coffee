class @NanoUI
  constructor: (@bus, @fragment = document) ->
    @bus.on "serverUpdate", @serverUpdate
    @bus.on "update",       @update
    @bus.on "render",       @render
    @bus.on "memes",        @render

    @initialized = false
    @layoutRendered = false
    @contentRendered = false

    @data = {}
    @initialData = JSON.parse @fragment.query("#data").data "initial"

    unless @initialData? or
    not ("data" of @initialData or "config" of @initalData)
      @bus.emit "error", "Initial data did not load correctly."
      return


  serverUpdate: (dataString) =>
    try
      data = JSON.parse(dataString)
    catch error
      NanoBus.emit "error", \
        "#{error.fileName}:#{error.lineNumber} #{error.message}"
      return

    @bus.emit "update", data
    return


  update: (data) =>
    unless data.data?
      if @data.data?
        data.data = @data.data
      else
        data.data = {}

    @data = data

    @bus.emit "render", @data if @initialized
    @bus.emit "updated"
    return


  render: (data) =>
    data = @initialData unless @initialized

    try
      if not @layoutRendered or data.config.autoUpdateLayout
        layout = @fragment.query("#layout")
        layout.innerHTML = TMPL[data.config.templates.layout]\
          (data.data, data.config, helpers)

        @layoutRendered = true
        @bus.emit "layoutRendered"

      if not @contentRendered or data.config.autoUpdateContent
        content = @fragment.query("#content")
        content.innerHTML = TMPL[data.config.templates.content]\
          (data.data, data.config, helpers)

        @contentRendered = true
        @bus.emit "contentRendered"

    catch error
      @bus.emit "error", \
        "#{error.fileName}:#{error.lineNumber} #{error.message}"
      return

    @bus.emit "rendered", data
    unless @initialized
      @initialized = true
      @bus.emit "initialized"
    return

  bycall: (action, params = {}) =>
    params.src = @data.config.ref
    params.nano = action

    location.href = util.href null, params

  close: (params = {}) =>
    params.command = "nanoclose #{@data.config.ref}"

    @winset "is-visible", "false"
    location.href = util.href "winset", params

  winset: (key, value, params = {}) =>
    params["#{@data.config.window.ref}.#{key}"] = value

    location.href = util.href "winset", params

  setPos: (x, y) ->
    @winset "pos", "#{x},#{y}"

  setSize: (w, h) ->
    @winset "size", "#{w},#{h}"
