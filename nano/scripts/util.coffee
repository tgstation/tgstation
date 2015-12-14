@util =
  extend: (first, second) ->
    Object.keys(second).forEach (key) ->
      secondVal = second[key]
      if secondVal and Object::toString.call(secondVal) is "[object Object]"
        first[key] = first[key] or {}
        util.extend first[key], secondVal
      else
        first[key] = secondVal
      return

    first

  href: (url = "", params = {}) ->
    url = new Url("byond://#{url}")
    util.extend url.query, params
    url
