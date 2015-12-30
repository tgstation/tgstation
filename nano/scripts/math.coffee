# Custom extensions to the built-in 'Math' object.
module.exports = Math

# Helper to limit a number to be inside 'min' and 'max'.
module.exports.clamp = (number, min, max) ->
  Math.max min, Math.min number, max

# Helper to round a number to 'decimals' decimals.
module.exports.fixed = (number, decimals = 1) ->
  Number Math.round(number + "e" + decimals) + "e-" + decimals
