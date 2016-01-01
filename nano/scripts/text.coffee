module.exports =
  upperCaseFirst: (str) ->
    str[0].toUpperCase() + str[1..].toLowerCase()
  titleCase: (str) ->
    str.replace /\w\S*/g, @upperCaseFirst
