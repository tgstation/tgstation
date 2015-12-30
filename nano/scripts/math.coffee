# Extensions to the built-in 'Math' object.

# Helper to limit a number to be inside 'min' and 'max'.
Math.clamp = (number, min, max) ->
  Math.max min, Math.min number, max

# Helper to round a number to 'decimals' decimals.
Math.fixed = (number, decimals = 1) ->
  Number Math.round(number + "e" + decimals) + "e-" + decimals
