@Helpers =
  link: (text = "", icon = "", parameters = {}, status = "", class = "") ->
    parameters = window.Util.href(parameters)

    if !!icon
      icon = "<i class='pending fa fa-fw \
      fa-spinner fa-pulse'></i><i class='main fa fa-fw fa-#{icon}'></i>"
      class += " iconed"

    if !!status
      "<div unselectable='on' class='link inactive \
        #{status} #{class}'>#{icon}#{text}</div>"
    else
      "<div unselectable='on' class='link active \
        #{class}' data-href='#{parameters}'>#{icon}#{text}</div>"


  bar: (value = 0, min = 0, max = 100, class = "", text = "") ->
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
    <span class='barFill #{class}' style='width: #{percentage}%;'></span> \
    <span class='barText #{class}'>#{text}</span> \
    </div>"


  round: (number) ->
    Math.round number


  fixed: (number, decimals = 1) ->
    Number Math.round(number + "e" + decimals) + "e-" + decimals


  floor: (number) ->
    Math.floor number


  ceil: (number) ->
    Math.ceil number
