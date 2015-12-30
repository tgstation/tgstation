# Helper to animate a key ('animated') on a Ractive component ('ractive'), replacing 'replace' in the keypath with 'replaceWith'.
module.exports = (ractive, animated, replace = "data", replaceWith = "animated") ->
  ractive.observe animated.join(" "), (newkey, oldkey, keypath) ->
    ractive.animate keypath.replace(replace, replaceWith), newkey
