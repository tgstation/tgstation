class @NanoUI
  constructor: (@bus, @fragment = document) ->
    @bus.on "serverUpdate", @serverUpdate
    @bus.on "update",       @update
    @bus.on "render",       @render
    @bus.on "memes",        @render

    @initialized = false

    @data = {}
    @initialData = JSON.parse @fragment.query("#data").data "initial"

    unless @initialData? or
    not ("data" of @initialData or "config" of @initalData)
      @error "Initial data did not load correctly."

  serverUpdate: (dataString) =>
    try
      data = JSON.parse(dataString)
    catch error
      @error error

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
      if not @initialized
        layout = @fragment.query("#layout")
        layout.innerHTML = TMPL[data.config.templates.layout]\
          (data.data, data.config, helpers)

      content = @fragment.query("#content")
      content.innerHTML = TMPL[data.config.templates.content]\
        (data.data, data.config, helpers)

    catch error
      @error error
      return

    @bus.emit "rendered", data
    if not @initialized
      @initialized = true
      @data = @initialData
      @bus.emit "initialized", data

  bycall: (action, params = {}) =>
    params.src = @data.config.ref
    params.nano = action
    location.href = util.href null, params

  error: (error, params = {}) ->
    if error instanceof Error
      error = "#{error.fileName}:#{error.lineNumber} #{error.message}"
    params.nano_error = error
    location.href = util.href null, params

  log: (message, params = {}) ->
    params.nano_log = message
    location.href = util.href null, params

  close: (params = {}) =>
    params.command = "nanoclose #{@data.config.ref}"
    @winset "is-visible", "false"
    location.href = util.href "winset", params

  winset: (key, value, params = {}) =>
    params["#{@data.config.window.ref}.#{key}"] = value
    location.href = util.href "winset", params
