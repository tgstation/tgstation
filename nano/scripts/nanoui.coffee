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
      data = JSON.parse dataString.replace /ÿ/g, ""
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
        @fragment.query("body").classList.add data.config.layout
        layout = @fragment.query("#layout")
        layout.innerHTML = TMPL[data.config.templates.layout](data.data, data.config, helpers)

      content = @fragment.query("#content")
      content.innerHTML = TMPL[data.config.templates.content](data.data, data.config, helpers)

    catch error
      @error error
      return

    @bus.emit "rendered", data
    if not @initialized
      @initialized = true
      @data = @initialData
      @bus.emit "initialized", data

  act: (action, params = {}) =>
    params.src = @data.config.ref
    params.nano = action
    location.href = util.href null, params

  error: (error, params = {}) ->
    @act {nano_error: error}

  close: =>
    params =
      command: "nanoclose #{@data.config.ref}"
    @winset "is-visible", "false"
    location.href = util.href "winset", params

  winset: (key, value, window) =>
    window = @data.config.window.ref unless window?
    params =
      "#{window}.#{key}": value
    location.href = util.href "winset", params
