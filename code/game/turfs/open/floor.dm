/// Anything above a lattice should go here.
/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	flags_1 = NO_SCREENTIPS_1 | CAN_BE_DIRTY_1
	turf_flags = IS_SOLID
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR

	thermal_conductivity = 0.02
	heat_capacity = 20000
	tiled_dirt = TRUE


	overfloor_placed = TRUE
	damaged_dmi = 'icons/turf/damaged.dmi'
	/// Path of the tile that this floor drops
	var/floor_tile = null
	/// Determines if you can deconstruct this with a RCD
	var/rcd_proof = FALSE

/turf/open/floor/Initialize(mapload)
	. = ..()
	if(mapload && prob(33))
		MakeDirty()

	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/floor/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/burnt_states()
	return list()

/turf/open/floor/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/open/floor/ex_act(severity, target)
	. = ..()

	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	if(is_explosion_shielded(severity))
		return FALSE

	if(target)
		severity = EXPLODE_LIGHT

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			switch(rand(1, 3))
				if(1)
					if (!ispath(baseturf_at_depth(2), /turf/open/floor))
						attempt_lattice_replacement()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
		if(EXPLODE_LIGHT)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

	return FALSE

/turf/open/floor/is_explosion_shielded(severity)
	if(severity >= EXPLODE_DEVASTATE)
		return FALSE
	for(var/obj/blocker in src)
		if(blocker.density)
			return TRUE
	return FALSE

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/// Things seem to rely on this actually returning plating. Override it if you have other baseturfs.
/turf/open/floor/proc/make_plating(force = FALSE)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

///For when the floor is placed under heavy load. Calls break_tile(), but exists to be overridden by floor types that should resist crushing force.
/turf/open/floor/proc/crush()
	break_tile()

/turf/open/floor/ChangeTurf(path, new_baseturfs, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.setDir(old_dir)
	W.update_appearance()
	return W

/turf/open/floor/attackby(obj/item/object, mob/living/user, list/modifiers)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return .
	if(overfloor_placed && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, modifiers)
		return TRUE
	if(user.combat_mode && istype(object, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/sheets = object
		return sheets.on_attack_floor(src, user, modifiers)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(overfloor_placed && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, list/modifiers)
	if(T.turf_type == type && T.turf_dir == dir)
		return
	var/obj/item/crowbar/CB = user.is_holding_tool_quality(TOOL_CROWBAR)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, modifiers)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, force_plating)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken plating."))
	else
		if(user && !silent)
			to_chat(user, span_notice("You remove the floor tile."))
		if(make_tile)
			spawn_tile()
	return make_plating(force_plating)

/turf/open/floor/proc/has_tile()
	return floor_tile

/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return null
	return new floor_tile(src)

/turf/open/floor/singularity_pull(atom/singularity, current_size)
	..()
	var/sheer = FALSE
	switch(current_size)
		if(STAGE_THREE)
			if(prob(30))
				sheer = TRUE
		if(STAGE_FOUR)
			if(prob(50))
				sheer = TRUE
		if(STAGE_FIVE to INFINITY)
			if(prob(70))
				sheer = TRUE
	if(sheer)
		if(has_tile())
			remove_tile(null, TRUE, TRUE, TRUE)


/turf/open/floor/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/acid_melt()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
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
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 5 SECONDS, "cost" = 33)

	return FALSE

/// if you are updating this make to to update /turf/open/misc/rcd_act() too
/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_TURF)
			if(rcd_data["[RCD_DESIGN_PATH]"] != /turf/open/floor/plating/rcd)
				return FALSE

			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_act(user, the_rcd, rcd_data)

			place_on_top(/turf/closed/wall)
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
		if(RCD_DECONSTRUCT)
			if(rcd_proof)
				balloon_alert(user, "it's too thick!")
				return FALSE
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			return TRUE
	return FALSE

/turf/open/floor/rust_turf()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return
	ChangeTurf(/turf/open/floor/plating)
	return ..()

/turf/open/floor/material
	name = "floor"
	icon_state = "materialfloor"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	floor_tile = /obj/item/stack/tile/material

/turf/open/floor/material/has_tile()
	return LAZYLEN(custom_materials)

/turf/open/floor/material/spawn_tile()
	. = ..()
	if(.)
		var/obj/item/stack/tile = .
		tile.set_custom_materials(custom_materials)
