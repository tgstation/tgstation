//turf frost - these are children of alien weeds because they're basically identical
//exposure to air above T20C will slowly melt them, wetting the floor as they melt
/obj/structure/alien/weeds/frost
	name = "frost"
	desc = "A thin frost covers the floor."

	icon = 'icons/obj/frost.dmi'
	icon_state = "frost"

	var/super_coefficient = 1 //for making the frost better, may be used in the future for more costly/powerful abilties or something

	health = 20
	max_temp_sustainable = T20C //any hotter than room temp and these'll start to melt
	temp_damage = 2
	type_of_weed = /obj/structure/alien/weeds/frost

	var/static/list/frostImageCache

/obj/structure/alien/weeds/frost/setImageCache()
	if(!frostImageCache || !frostImageCache.len)
		frostImageCache = list()
		frostImageCache.len = 4
		frostImageCache[WEED_NORTH_EDGING] = image('icons/obj/frost.dmi', "frost_side_n", layer=2.11, pixel_y = -32)
		frostImageCache[WEED_SOUTH_EDGING] = image('icons/obj/frost.dmi', "frost_side_s", layer=2.11, pixel_y = 32)
		frostImageCache[WEED_EAST_EDGING] = image('icons/obj/frost.dmi', "frost_side_e", layer=2.11, pixel_x = -32)
		frostImageCache[WEED_WEST_EDGING] = image('icons/obj/frost.dmi', "frost_side_w", layer=2.11, pixel_x = 32)

/obj/structure/alien/weeds/frost/getWeedOverlay(C)
	return frostImageCache["[C]"]

/obj/structure/alien/weeds/frost/New(super_coefficient = src.super_coefficient)
	..()
	health *= super_coefficient
	max_temp_sustainable *= super_coefficient
	temp_damage /= super_coefficient

/obj/structure/alien/weeds/frost/Destroy()
	. = ..()
	var/turf/simulated/T = loc
	T.MakeSlippery()

/obj/structure/alien/weeds/frost/node
	name = "thick frost"
	desc = "A thick frost covers the floor. It appears to be making the area around it colder."

	icon_state = "frostnode"

	node_range = NODERANGE
	var/temperature_delta = 15 //this value is subtracted from T20C to get the temperature this node attempts to lowers its tile to

/obj/structure/alien/weeds/frost/node/New(super_coefficient = src.super_coefficient)
	..(loc, src, super_coefficient)
	node_range *= super_coefficient
	temperature_delta *= super_coefficient
	SSobj.processing += src

/obj/structure/alien/weeds/frost/node/Destroy()
	SSobj.processing -= src
	return ..()

/obj/structure/alien/weeds/frost/node/process()
	var/turf/simulated/T = loc
	var/datum/gas_mixture/A = new

	A.temperature = Clamp(T20C - temperature_delta, TCMB, T.air.temperature - temperature_delta) //ensures that we don't get too cold from frost; standard lower bound is 5 C. Also prevents temperatures of 0 or less.
	T.air.temperature_share(A, WINDOW_HEAT_TRANSFER_COEFFICIENT) //same value as h/e pipes. I dunno mang it works for them.
	qdel(A)

/obj/structure/alien/weeds/frost/node/infinity
	super_coefficient = INFINITY //lmao