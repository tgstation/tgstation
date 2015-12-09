@Helpers =
  link: (text = "", icon = "", parameters = {}, \
  status = "", elementClass = "") ->
    parameters = window.Util.href(parameters)

    if !!icon
      icon = "<i class='pending fa fa-fw \
      fa-spinner fa-pulse'></i><i class='main fa fa-fw fa-#{icon}'></i>"
      elementClass += " iconed"

    if !!status
      "<div unselectable='on' class='link inactive \
        #{status} #{elementClass}'>#{icon}#{text}</div>"
    else
      "<div unselectable='on' class='link active \
        #{elementClass}' data-href='#{parameters}'>#{icon}#{text}</div>"


  bar: (value = 0, rangeMin = 0, rangeMax = 100,
  styleClass = "", barText = "") ->
    if rangeMin < rangeMax
      if value < rangeMin
        value = rangeMin
      else if value > rangeMax
        value = rangeMax
    else
      if value > rangeMin
        value = rangeMin
      else if value < rangeMax
        value = rangeMax

    percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100)

    "<div class='bar'> \
    <span class='barFill #{styleClass}' style='width: #{percentage}%;'></span> \
    <span class='barText #{styleClass}'>#{barText}</span> \
    </div>"


  round: (number) ->
    Math.round number


  fixed: (number, decimals = 1) ->
    Number Math.round(number + "e" + decimals) + "e-" + decimals


  floor: (number) ->
    Math.floor number


  ceil: (number) ->
    Math.ceil number
