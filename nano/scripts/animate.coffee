module.exports = (ractive, animated, replace = "data", replaceWith = "animated") ->
  ractive.observe animated.join(" "), (newkey, oldkey, keypath) ->
    ractive.animate keypath.replace(replace, replaceWith), newkey
