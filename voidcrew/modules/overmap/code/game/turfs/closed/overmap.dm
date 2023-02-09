/turf/closed/overmap_edge
	icon = 'voidcrew/modules/overmap/icons/turf/overmap.dmi'
	icon_state = "overmap"
	space_lit = TRUE

/turf/closed/overmap_edge/Initialize(mapload)
	. = ..()

	name = "[x]-[(y + 1) - OVERMAP_SOUTH_SIDE_COORD]"
	var/list/numbers = list()

	if(x == OVERMAP_LEFT_SIDE_COORD || x == OVERMAP_RIGHT_SIDE_COORD)
		numbers += list("[round(((y + 1) - (OVERMAP_SOUTH_SIDE_COORD)) / 10)]","[round(((y + 1) - (OVERMAP_SOUTH_SIDE_COORD)) % 10)]")
		if(y == OVERMAP_SOUTH_SIDE_COORD || y == OVERMAP_NORTH_SIDE_COORD)
			numbers += "-"
	if(y == OVERMAP_SOUTH_SIDE_COORD || y == OVERMAP_NORTH_SIDE_COORD)
		numbers += list("[round(x/10)]","[round(x%10)]")

	for(var/i = 1 to numbers.len)
		var/image/I = image('voidcrew/modules/overmap/icons/effects/numbers.dmi', numbers[i])
		I.pixel_x = 5*i - 2
		I.pixel_y = world.icon_size/2 - 3
		if(y == OVERMAP_SOUTH_SIDE_COORD)
			I.pixel_y = 3
			I.pixel_x = 5*i + 4
		if(y == OVERMAP_NORTH_SIDE_COORD)
			I.pixel_y = world.icon_size - 9
			I.pixel_x = 5*i + 4
		if(x == OVERMAP_LEFT_SIDE_COORD)
			I.pixel_x = 5*i - 2
		if(x == OVERMAP_RIGHT_SIDE_COORD)
			I.pixel_x = 5*i + 2
		overlays += I

