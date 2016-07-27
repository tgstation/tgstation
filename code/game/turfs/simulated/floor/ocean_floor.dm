//Ocean tiles constantly create water above them. If the water somehow disappears, it returns shortly.
/turf/open/floor/ocean
	name = "ocean floor"
	desc = "Wet sand covered in water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	var/simulated_depth = 1 //The depth of the water on this tile

/turf/open/floor/ocean/New()
	..()
	new/obj/effect/water/infinite(src, simulated_depth, 100)

/turf/open/floor/ocean/Destroy()
	return //This is supposed to act like space on applicable maps

/turf/open/floor/ocean/shallow
	simulated_depth = 250

/turf/open/floor/ocean/deep
	simulated_depth = 500

/turf/open/floor/ocean/lightless
	simulated_depth = 900

/turf/open/floor/ocean/abyss
	simulated_depth = 1005
