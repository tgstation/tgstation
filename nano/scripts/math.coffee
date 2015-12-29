Math.clamp = (number, min, max) ->
  Math.max min, Math.min number, max

Math.fixed = (number, decimals = 1) ->
  Number Math.round(number + "e" + decimals) + "e-" + decimals

module.exports = Math
