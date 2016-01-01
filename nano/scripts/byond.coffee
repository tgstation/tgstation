encode = encodeURIComponent

module.exports =
  href: (params = {}, url = "") -> # Helper to generate a BYOND href given 'params' as an object (with an optional 'url' for eg winset).
    params = (Object.keys(params).map (key) -> "#{encode(key)}=#{encode(params[key])}").join("&")
    "byond://#{url}?#{params}"
  act: (src, action, params = {}) -> # Helper to make a BYOND ui_act() call on the NanoUI 'src' given an 'action' and optional 'params'.
    params.src = src
    params.action = action
    location.href = @href params
  winset: (window, key, value) -> # Helper to make a BYOND winset() call on 'window', setting 'key' to 'value'
    location.href = @href {"#{window}.#{key}": value}, "winset"
