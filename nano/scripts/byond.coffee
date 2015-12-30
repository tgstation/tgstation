encode = encodeURIComponent

# Helper to generate a BYOND href given 'params' as an object (with an optional 'url' for eg winset).
href = (params = {}, url = "") ->
  params = (Object.keys(params).map (key) -> "#{encode(key)}=#{encode(params[key])}").join("&")
  "byond://#{url}?#{params}"

# Helper to make a BYOND ui_act() call on the NanoUI 'src' given an 'action' and optional 'params'.
act = (src, action, params = {}) ->
  params.src = src
  params.action = action
  location.href = href params

# Helper to make a BYOND winset() call on 'window', setting 'key' to 'value'
winset = (window, key, value) ->
  location.href = href {"#{window}.#{key}": value}, "winset"

module.exports =
  act: act
  href: href
  winset: winset
