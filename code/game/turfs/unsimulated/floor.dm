/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/unsimulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0

/turf/unsimulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/unsimulated/floor/engine
	icon_state = "engine"

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)


/turf/unsimulated/floor/grass
	icon_state = "grass"

