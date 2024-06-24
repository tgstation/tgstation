/obj/structure/railing
	icon = 'monkestation/code/modules/aesthetics/icons/railing_basic.dmi'
	icon_state = "railing0-1"

	obj_flags = IGNORE_DENSITY | CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR
	custom_materials = list(/datum/material/iron = 100)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

	var/neighbor_status = list() ///list of smoothing we need doing
	var/standard_smoothing = TRUE

/obj/structure/railing/wood
	custom_materials = list(/datum/material/wood = 100)

/obj/structure/railing/Initialize(mapload)
	. = ..()
	if(!standard_smoothing)
		material_flags = NONE
	return INITIALIZE_HINT_LATELOAD

/obj/structure/railing/LateInitialize()
	. = ..()
	if(anchored)
		update_icon()


/obj/structure/railing/setDir(newdir)
	. = ..()
	if(anchored)
		update_icon()

/obj/structure/railing/Destroy()
	. = ..()
	for(var/thing in range(1, src))
		var/turf/T = thing
		for(var/obj/structure/railing/R in T.contents)
			R.update_icon()

/obj/structure/railing/proc/check_neighbors(updates = TRUE)
	neighbor_status = list()
	var/Rturn = turn(src.dir, -90)
	var/Lturn = turn(src.dir, 90)

	for(var/obj/structure/railing/R in get_turf(src))
		if((R.dir == Lturn) && R.anchored)
			neighbor_status |= "corneroverlay_l"
			if(updates)
				R.update_icon(FALSE)
		if((R.dir == Rturn) && R.anchored)
			neighbor_status |= "corneroverlay_r"
			if(updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, Lturn))
		if((R.dir == src.dir) && R.anchored)
			neighbor_status |= "frontoverlay_l"
			if(updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, Rturn))
		if((R.dir == src.dir) && R.anchored)
			neighbor_status |= "frontoverlay_r"
			if (updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, (Lturn + src.dir)))
		if((R.dir == Rturn) && R.anchored)
			neighbor_status |= "frontoverlay_l"
			if (updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, (Rturn + src.dir)))
		if((R.dir == Lturn) && R.anchored)
			neighbor_status |= "mcorneroverlay_l"
			if (updates)
				R.update_icon(FALSE)

	///corner hell
	///we are basically checking if 2 or more cardinal directions exist here so we can set our dir


/obj/structure/railing/update_icon(update_neighbors = TRUE)
	. = ..()
	if(standard_smoothing)
		check_neighbors(update_neighbors)
		overlays.Cut()

		var/turf/turf = get_turf(src)
		if(dir == SOUTH)
			SET_PLANE(src, GAME_PLANE_FOV_HIDDEN, turf)
			layer = ABOVE_MOB_LAYER + 0.01

		else if(dir != NORTH)
			SET_PLANE(src, GAME_PLANE_FOV_HIDDEN, turf)
		else
			SET_PLANE(src, GAME_PLANE, turf)
			layer = initial(layer)

		if(!neighbor_status || !anchored)
			icon_state = "railing0-[density]"
		else
			icon_state = "railing1-[density]"

			if(("corneroverlay_l" in neighbor_status) && ("corneroverlay_r" in neighbor_status))
				icon_state = "blank"


			var/turf/right_turf = get_step(src, turn(src.dir, -90))
			var/turf/left_turf = get_step(src, turn(src.dir, 90))

			if((!locate(/obj/structure/railing) in right_turf.contents))
				if(!("mcorneroverlay_l" in neighbor_status))
					overlays += image(icon, "frontend_r[density]")
				else
					overlays += image(icon, "frontoverlay_r[density]")


			if((!locate(/obj/structure/railing) in left_turf.contents))
				if(!("mcorneroverlay_l" in neighbor_status))
					overlays += image(icon, "frontend_l[density]")
				else
					overlays += image(icon, "frontoverlay_l[density]")


			if("corneroverlay_l" in neighbor_status)
				overlays += image(icon, "corneroverlay_l[density]")
			if("corneroverlay_r" in neighbor_status)
				overlays += image(icon, "corneroverlay_r[density]")
			if("frontoverlay_l" in neighbor_status)
				overlays += image(icon, "frontoverlay_l[density]")
			if("frontoverlay_r" in neighbor_status)
				overlays += image(icon, "frontoverlay_r[density]")
			if("mcorneroverlay_l" in neighbor_status)
				var/pix_offset_x = 0
				var/pix_offset_y = 0
				switch(dir)
					if(NORTH)
						pix_offset_x = 32
					if(SOUTH)
						pix_offset_x = -32
					if(EAST)
						pix_offset_y = -32
					if(WEST)
						pix_offset_y = 32
				overlays += image(icon, "mcorneroverlay_l[density]", pixel_x = pix_offset_x, pixel_y = pix_offset_y)
