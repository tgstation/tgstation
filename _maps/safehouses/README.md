# Safe House

## Creating a new safe house

1. Create a new 7x6 map inside the `_maps\safe_houses` folder.
2. Create a new dm file inside `modules\bitmining\virtual_domain\safe_houses` folder.
3. Ensure the bottom left corner is using an area passthrough. If you don't, it won't generate.
4. Make sure that your safe houses have all of these areas: The noop area in the BL corner, a minimum [1x1] send point, and a minimum [1x1] exits (THREE RECOMMENDED).
5. Ideally, leave 3 spaces for gear. This has usually been xy [1x1] [1x2] [1x3]

## Areas, explained

1. Main: The safe house zone. Ensures power, ambience, and air.
2. Send: The area that the player places instance rewards on to send back to the station.
3. Exit: Technically, you can place however many. Virtual Dom was built to accomodate 3. The larger the area is, the more times netchairs can spawn into it. Effectively, these are retries and additional players.

## Notes

- Safe houses are intended to be 7x6 in size. You're not technically limited to this, but consider that the safe house spawn point is positioned to account for it.
  It is probably okay to mix and match if you're positive the map accounts for it, otherwise overlapping may occur.
- Consider that avatars are not invincible and still require air. If you're making a safe house, it should start with an area that accommodates for this.
- To be compatible with other maps, your safe house should have a route open from the top center xy [3x0] of the map.
- Some maps can alter what is spawned into the safehouse by placing objects in the safehouse area. I'm using the left corner, starting from the top, for things like space gear. 

