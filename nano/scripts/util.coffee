@util =
  extend: (first, second) ->
    Object.keys(second).forEach (key) ->
      secondVal = second[key]
      if secondVal and Object::toString.call(secondVal) is "[object Object]"
        first[key] = first[key] or {}
        util.extend first[key], secondVal
      else
        first[key] = secondVal
    first

  href: (url = "", params = {}) ->
    "byond://#{url}?" + Object.keys(params).map (key) ->
      "#{encodeURIComponent(key)}=#{encodeURIComponent(params[key])}"
    .join("&")
