//turf frost - these are children of alien weeds because they're basically identical
//exposure to air above T20C will slowly melt them, wetting the floor as they melt
/obj/structure/alien/weeds/frost
	name = "frost"
	desc = "A thin frost covers the floor."

	icon = 'icons/obj/frost.dmi'
	icon_state = "frost"

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

/obj/structure/alien/weeds/frost/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > max_temp_sustainable)
		//TODO: make it wet ;)

/obj/structure/alien/weeds/frost/node
	name = "thick frost"
	desc = "A thick frost covers the floor. It appears to be making the area around it colder."

	icon_state = "frostnode"

	noderange = NODERANGE

/obj/structure/alien/weeds/frost/node/New()
	..(loc, src)