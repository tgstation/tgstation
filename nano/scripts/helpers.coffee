@helpers =
  link: (text = "", icon = "", action = "", params = {}, status = "", klass = "") ->
    params = JSON.stringify params

    if !!icon
      icon = "<i class='fa fa-fw fa-#{icon}'></i>"
      klass += " iconed"

    if !!status
      "<span unselectable='on' class='link inactive #{status} #{klass}'>#{icon}#{text}</span>"
    else
      "<span unselectable='on' class='link active #{klass}' data-action='#{action}' data-params='#{params}'>#{icon}#{text}</span>"

  bar: (value = 0, min = 0, max = 100, klass = "", text = "") ->
    if min < max
      if value < min
        value = min
      else if value > max
        value = max
    else
      if value > min
        value = min
      else if value < max
        value = max

    percentage = Math.round((value - min) / (max - min) * 100)

    "<div class='bar'> \
    <span class='barFill #{klass}' style='width: #{percentage}%;'></span> \
    <span class='barText'>#{text}</span> \
    </div>"

  round: (number) ->
    Math.round number

  fixed: (number, decimals = 1) ->
    Number Math.round(number + "e" + decimals) + "e-" + decimals

  floor: (number) ->
    Math.floor number

  ceil: (number) ->
    Math.ceil number
