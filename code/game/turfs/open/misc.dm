/// Used as a parent type for types that want to allow construction, but do not want to be floors
/// I wish I could use components for turfs at scale
/// Please do not bloat this. Love you <3
/turf/open/misc
	name = "coder/mapper fucked up"
	desc = "report on github please"

	flags_1 = NO_SCREENTIPS_1
	turf_flags = CAN_BE_DIRTY_1 | IS_SOLID | NO_RUST

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR

	thermal_conductivity = 0.04
	heat_capacity = 10000
	tiled_dirt = TRUE

/turf/open/misc/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(istype(W, /obj/item/stack/rods))
		build_with_rods(W, user)
		return TRUE
	else if(istype(W, /obj/item/stack/tile/iron))
		build_with_floor_tiles(W, user)
		return TRUE

/turf/open/misc/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/misc/ex_act(severity, target)
	. = ..()

	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	if(severity < EXPLODE_DEVASTATE && is_shielded())
		return FALSE

	if(target)
		severity = EXPLODE_LIGHT

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			switch(rand(1, 3))
				if(1 to 2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
		if(EXPLODE_LIGHT)
			if (prob(50))
				break_tile()
				hotspot_expose(1000,CELL_VOLUME)

	return TRUE

/turf/open/misc/is_shielded()
	for(var/obj/structure/A in contents)
		return TRUE

/turf/open/misc/blob_act(obj/structure/blob/B)
	return

/turf/open/misc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_TURF)
			if(the_rcd.rcd_design_path != /turf/open/floor/plating/rcd)
				return FALSE

			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_vals(user, the_rcd)

			return rcd_result_with_memory(
				list("delay" = 2 SECONDS, "cost" = 16),
				src, RCD_MEMORY_WALL,
			)
		if(RCD_WINDOWGRILLE)
			//default cost for building a grill for fulltile windows
			var/cost = 4
			var/delay = 1 SECONDS
			if(the_rcd.rcd_design_path  == /obj/structure/window)
				cost = 4
				delay = 2 SECONDS
			else if(the_rcd.rcd_design_path  == /obj/structure/window/reinforced)
				cost = 6
				delay = 2.5 SECONDS
			return rcd_result_with_memory(
				list("delay" = delay, "cost" = cost),
				src, RCD_MEMORY_WINDOWGRILLE,
			)
		if(RCD_AIRLOCK)
			if(ispath(the_rcd.rcd_design_path, /obj/machinery/door/airlock/glass))
				return list("delay" = 5 SECONDS, "cost" = 20)
			else
				return list("delay" = 5 SECONDS, "cost" = 16)
		if(RCD_STRUCTURE)
			var/static/list/structure_costs = list(
				/obj/structure/reflector = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/structure/girder = list("delay" = 1.3 SECONDS, "cost" = 8),
				/obj/structure/frame/machine/secured = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/structure/frame/computer/rcd = list("delay" = 2 SECONDS, "cost" = 20),
				/obj/structure/floodlight_frame = list("delay" = 3 SECONDS, "cost" = 20),
				/obj/structure/chair = list("delay" = 1 SECONDS, "cost" = 4),
				/obj/structure/chair/stool/bar = list("delay" = 0.5 SECONDS, "cost" = 4),
				/obj/structure/table = list("delay" = 2 SECONDS, "cost" = 8),
				/obj/structure/bed = list("delay" = 2.5 SECONDS, "cost" = 8),
				/obj/structure/rack = list("delay" = 2.5 SECONDS, "cost" = 4),
			)

			var/list/design_data = structure_costs[the_rcd.rcd_design_path]
			if(!isnull(design_data))
				return design_data

			for(var/structure in structure_costs)
				if(ispath(the_rcd.rcd_design_path, structure))
					return structure_costs[structure]

			return FALSE

	return FALSE

/turf/open/misc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_TURF)
			if(rcd_data["[RCD_DESIGN_PATH]"] != /turf/open/floor/plating/rcd)
				return FALSE

			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_act(user, the_rcd, rcd_data)

			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_WINDOWGRILLE)
			//check if we are building a window
			var/obj/structure/window/window_path = rcd_data["[RCD_DESIGN_PATH]"]
			if(!ispath(window_path))
				CRASH("Invalid window path type in RCD: [window_path]")

			//allow directional windows to be built without grills
			if(!initial(window_path.fulltile))
				if(!valid_build_direction(src, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "window already here!")
					return FALSE
				var/obj/structure/window/WD = new window_path(src, user.dir)
				WD.set_anchored(TRUE)
				return TRUE

			//build grills to deal with full tile windows
			if(locate(/obj/structure/grille) in src)
				return FALSE
			var/obj/structure/grille/new_grille = new(src)
			new_grille.set_anchored(TRUE)
			return TRUE
		if(RCD_AIRLOCK)
			var/obj/machinery/door/airlock_type = rcd_data["[RCD_DESIGN_PATH]"]

			if(ispath(airlock_type, /obj/machinery/door/window))
				if(!valid_build_direction(src, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "there's already a windoor!")
					return FALSE
				for(var/obj/machinery/door/door in src)
					if(istype(door, /obj/machinery/door/window))
						continue
					balloon_alert(user, "there's already a door!")
					return FALSE
				//create the assembly and let it finish itself
				var/obj/structure/windoor_assembly/assembly = new (src, user.dir)
				assembly.secure = ispath(airlock_type, /obj/machinery/door/window/brigdoor)
				assembly.electronics = the_rcd.airlock_electronics.create_copy(assembly)
				assembly.finish_door()
				return TRUE

			for(var/obj/machinery/door/door in src)
				if(door.sub_door)
					continue
				balloon_alert(user, "there's already a door!")
				return FALSE
			//create the assembly and let it finish itself
			var/obj/structure/door_assembly/assembly = new (src)
			if(initial(airlock_type.glass))
				assembly.glass = TRUE
				assembly.glass_type = airlock_type
			else
				assembly.airlock_type = airlock_type
			assembly.electronics = the_rcd.airlock_electronics.create_copy(assembly)
			assembly.finish_door()
			return TRUE
		if(RCD_STRUCTURE)
			var/atom/movable/design_type = rcd_data["[RCD_DESIGN_PATH]"]

			//map absolute types to basic subtypes
			var/atom/movable/locate_type = design_type
			if(ispath(locate_type, /obj/structure/frame/machine/secured))
				locate_type = /obj/structure/frame/machine
			if(ispath(locate_type, /obj/structure/frame/computer/rcd))
				locate_type = /obj/structure/frame/computer
			if(ispath(locate_type, /obj/structure/floodlight_frame/completed))
				locate_type = /obj/structure/floodlight_frame
			if(locate(locate_type) in src)
				return FALSE

			var/atom/movable/design = new design_type(src)
			var/static/list/dir_types = list(
				/obj/structure/chair,
				/obj/structure/table,
				/obj/structure/rack,
				/obj/structure/bed,
			)
			if(is_path_in_list(locate_type, dir_types))
				design.setDir(user.dir)
			return TRUE
	return FALSE
