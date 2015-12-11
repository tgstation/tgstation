class @Util
  constructor: (@bus, @fragment = document) ->
    @urlParameters = JSON.parse @fragment.query("#data").data "url-parameters"

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


  href: (parameters) =>
    url = new Url("byond://")
    @extend url.query, @extend(parameters, @urlParameters)

    url
