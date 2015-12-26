class NanoUI
  constructor: ->
    @laidout = false

    @dragging = false
    @resizing = false

    try
      @data = JSON.parse document.query("#data").getAttribute "data-initial"
    catch error
      @error error
    if not (@data? and "data" of @data and "config" of @data)
      @error "Initial data did not load correctly."

    @render @data
    @chrome = new Chrome this, @data

    @initialized.dispatch @data
    @incoming.add @update
  initialized: new MiniSignal
  incoming: new MiniSignal

  update: (dataString) =>
    try
      @data = JSON.parse dataString
    catch error
      @error error
    @render @data
    @updated.dispatch @data
  updated: new MiniSignal

  render: (data) =>
    try
      if not @laidout
        @laidout = true
        document.query("body").classList.add data.config.layout
        layout = TMPL[data.config.templates.layout](data.data, data.config, helpers)
        document.query("#layout").innerHTML = layout

      content = TMPL[data.config.templates.content](data.data, data.config, helpers)
      document.query("#content").innerHTML = content

      @rendered.dispatch @data
    catch error
      @error error
  rendered: new MiniSignal


  href: (params = {}, url = "") ->
    "byond://#{url}?" + Object.keys(params).map (key) ->
      "#{encodeURIComponent(key)}=#{encodeURIComponent(params[key])}"
    .join("&")

  act: (action, params = {}) =>
    params.src = @data.config.ref
    params.nano = action
    location.href = @href params, null
  error: (error) ->
    location.href = @href {nano_error: error}, null

  winset: (key, value, window) =>
    window = @data.config.window.ref unless window?
    location.href = @href {"#{window}.#{key}": value}, "winset"
  setPos: (x, y) =>
    @winset "pos", "#{x},#{y}"
  setSize: (w, h) =>
    @winset "size", "#{w},#{h}"
  focusMap: =>
    @winset "focus", 1, "mapwindow.map"

  close: =>
    @winset "is-visible", "false"
    location.href = @href {command: "nanoclose #{@data.config.ref}"}, "winset"
  minimize: =>
    @winset "is-minimized", "true"


@nanoui = new NanoUI
