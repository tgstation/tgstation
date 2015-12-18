@util =
  href: (url = "", params = {}) ->
    "byond://#{url}?" + Object.keys(params).map (key) ->
      "#{encodeURIComponent(key)}=#{encodeURIComponent(params[key])}"
    .join("&")
