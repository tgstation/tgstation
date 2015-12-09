@Util =
  extend: (first, second) ->
    Object.keys(second).forEach (key) ->
      secondVal = second[key]
      if secondVal and Object::toString.call(secondVal) is "[object Object]"
        first[key] = first[key] or {}
        @extend first[key], secondVal
      else
        first[key] = secondVal
      return

    first


  href: (parameters) ->
    baseParameters = JSON.parse(document.query("#data").data("url-parameters"))

    url = new Url("byond://")
    @extend url.query, @extend(parameters, baseParameters)

    url
