# Safe House

## Creating a new safe house

1. Create a new map inside the `_maps\safe_houses` folder using the TGM format.
2. Create a new dm file inside `modules\bitrunning\virtual_domain\safe_houses` folder..
3. Place exit and goal landmarks (obj/effect/landmark/bitrunning/..). Generally, 3 exits and 2 goals are ok.
4. Ideally, leave 3 spaces for gear. This has usually been xy [1x1] [1x2] [1x3]
5. Place the modular map connector at the bottom left tile.

## Notes

- Safe houses are intended to be 7x6 in size. You're not technically limited to this, but consider maps other maps might be using this size if you want it to be modular.
- Consider that avatars are not invincible and still require air. If you're making a safe house, it should start with an area that accommodates for this.
- For compatibility, your safe house should have a route open from the top center xy [3x0] of the map.
- If you want a custom safehouse for a custom map with no modularity, no problem. Make whatever sizes you want, just ensure there are exit and goal effects placed.
- Some maps can alter what is spawned into the safehouse by placing objects in the safehouse area. I'm using the left corner, starting from the top, for things like space gear.
