/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	layer = TILE_LAYER

/turf/unsimulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	layer = PLATING_LAYER

/turf/unsimulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/unsimulated/floor/engine
	icon_state = "engine"
	layer = PLATING_LAYER

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)