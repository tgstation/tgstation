href = (params = {}, url = "") ->
  "byond://#{url}?" + Object.keys(params).map (key) ->
    "#{encodeURIComponent(key)}=#{encodeURIComponent(params[key])}"
  .join("&")

act = (src, action, params = {}) ->
  params.src = src
  params.action = action
  location.href = href params, null

winset = (window, key, value) ->
  location.href = href {"#{window}.#{key}": value}, "winset"

module.exports =
  act: act
  href: href
  winset: winset
