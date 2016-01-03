byond = require "./byond"


module.exports =
  drag: (ractive, event) ->
    lock = (x, y) ->
      if x < 0 # Left
        x = 0
      if y < 0 # Top
        y = 0
      if x + window.innerWidth > screen.availWidth # Right
        x = screen.availWidth - window.innerWidth
      if y + window.innerHeight > screen.availHeight # Bottom
        y = screen.availHeight - window.innerHeight
      {x: x, y: y}

    if ractive.get "x"
      x = (event.screenX - ractive.get "x") + window.screenLeft
      y = (event.screenY - ractive.get "y") + window.screenTop
      if ractive.get "config.locked" then {x, y} = lock x, y # Lock to primary monitor.

      byond.winset ractive.get("config.window"), "pos", "#{x},#{y}"
    ractive.set x: event.screenX, y: event.screenY

  resize: (ractive, event) ->
    sane = (x, y) ->
      x = Math.clamp x, 100, screen.width
      y = Math.clamp y, 100, screen.height
      {x: x, y: y}

    if ractive.get "x"
      x = (event.screenX - ractive.get "x") + window.innerWidth
      y = (event.screenY - ractive.get "y") + window.innerHeight
      {x, y} = sane x, y

      byond.winset ractive.get("config.window"), "size", "#{x},#{y}"
    ractive.set x: event.screenX, y: event.screenY
