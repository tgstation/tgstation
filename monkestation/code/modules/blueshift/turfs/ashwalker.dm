/turf/closed/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/flashlight/flare/torch))
		return place_torch(attacking_item, user, params)

	return ..()

// Try to place a torch on the wall such that we can only see it from one side
/turf/closed/proc/place_torch(obj/item/flashlight/flare/torch/torch_to_place, mob/user, params)
	if(user.transferItemToLoc(torch_to_place, user.drop_location(), silent = FALSE))
		var/found_adjacent_turf = get_open_turf_in_dir(src, get_dir(src, user.loc))
		var/list/modifiers = params2list(params)

		// Center the icon where the user clicked.
		if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the wall turf)
			torch_to_place.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/3), world.icon_size/3)
			torch_to_place.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/3), world.icon_size/3)

		// Try to put the torch in the adjacent turf relative to the user. This way it's not visible from the other side of the wall
		if(found_adjacent_turf)
			torch_to_place.forceMove(found_adjacent_turf)
		else
			torch_to_place.forceMove(src) // no open turfs for some reason
			return TRUE

		// The item itself is in the adjacent turf, so we need to shift the icon one tile over to put it in the wall
		switch(get_dir(found_adjacent_turf, src))
			if(NORTH)
				torch_to_place.pixel_y += world.icon_size
			if(SOUTH)
				torch_to_place.pixel_y -= world.icon_size
			if(EAST)
				torch_to_place.pixel_x += world.icon_size
			if(NORTHEAST)
				torch_to_place.pixel_y += world.icon_size
				torch_to_place.pixel_x += world.icon_size
			if(SOUTHEAST)
				torch_to_place.pixel_y -= world.icon_size
				torch_to_place.pixel_x += world.icon_size
			if(WEST)
				torch_to_place.pixel_x -= world.icon_size
			if(NORTHWEST)
				torch_to_place.pixel_y += world.icon_size
				torch_to_place.pixel_x -= world.icon_size
			if(SOUTHWEST)
				torch_to_place.pixel_y -= world.icon_size
				torch_to_place.pixel_x -= world.icon_size
		return TRUE

/turf/open/floor/stone/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

/turf/open/floor/wood/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

/turf/open/misc/sandy_dirt/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

/turf/open/floor/bamboo/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/stone/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/wood/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
