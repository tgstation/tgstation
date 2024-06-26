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
	flags_1 = NO_SCREENTIPS_1
	turf_flags = CAN_BE_DIRTY_1 | IS_SOLID
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR

	thermal_conductivity = 0.04
	heat_capacity = 10000
	tiled_dirt = TRUE


	overfloor_placed = TRUE

	/// Determines the type of damage overlay that will be used for the tile
	var/damaged_dmi = 'icons/turf/damaged.dmi'
	var/broken = FALSE
	var/burnt = FALSE
	/// Path of the tile that this floor drops
	var/floor_tile = null
	/// Determines if you can deconstruct this with a RCD
	var/rcd_proof = FALSE

/turf/open/floor/Initialize(mapload)
	. = ..()

	if (PERFORM_ALL_TESTS(focus_only/valid_turf_states))
		var/static/list/previous_errors = list()

		if (!(type in previous_errors))
			if (broken != (icon_state in broken_states()))
				stack_trace("[icon_state] (from [type]), which should be [broken ? "NOT broken, IS" : "broken, IS NOT"]")
				previous_errors[type] = TRUE

			if (burnt != (icon_state in burnt_states()))
				stack_trace("[icon_state] (from [type]), which should be [burnt ? "NOT burnt, IS" : "burnt, IS NOT"]")
				previous_errors[type] = TRUE

	if(mapload && prob(33))
		MakeDirty()

	if(is_station_level(z))
		GLOB.station_turfs += src

/// Returns a list of every turf state considered "broken".
/// Will be randomly chosen if a turf breaks at runtime.
/turf/open/floor/proc/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/// Returns a list of every turf state considered "burnt".
/// Will be randomly chosen if a turf is burnt at runtime.
/turf/open/floor/proc/burnt_states()
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
	if(severity < EXPLODE_DEVASTATE && is_shielded())
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

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		return 1

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/turf/open/floor/break_tile()
	if(broken)
		return
	broken = TRUE
	update_appearance()

/turf/open/floor/burn_tile()
	if(burnt)
		return
	burnt = TRUE
	update_appearance()

/turf/open/floor/update_overlays()
	. = ..()
	if(broken)
		. += mutable_appearance(damaged_dmi, pick(broken_states()))
	else if(burnt)
		var/list/burnt_states = burnt_states()
		if(burnt_states.len)
			. += mutable_appearance(damaged_dmi, pick(burnt_states))
		else
			. += mutable_appearance(damaged_dmi, pick(broken_states()))

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

/turf/open/floor/attackby(obj/item/object, mob/living/user, params)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return .
	if(overfloor_placed && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
		return TRUE
	if((user.istate & ISTATE_HARM) && istype(object, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/sheets = object
		return sheets.on_attack_floor(user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(overfloor_placed && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type && T.turf_dir == dir)
		return
	var/obj/item/crowbar/CB = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

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

/turf/open/floor/singularity_pull(S, current_size)
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

/// if you are updating this make to to update /turf/open/misc/rcd_vals() too
/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_vals(user, the_rcd)
			return rcd_result_with_memory(
				list("mode" = RCD_FLOORWALL, "delay" = 2 SECONDS, "cost" = 16),
				src, RCD_MEMORY_WALL,
			)
		if(RCD_REFLECTOR)
			return list("mode" = RCD_REFLECTOR, "delay" = 2 SECONDS, "cost" = 20)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 5 SECONDS, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 5 SECONDS, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 5 SECONDS, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			//default cost for building a grill for fulltile windows
			var/cost = 4
			var/delay = 1 SECONDS
			if(the_rcd.window_type  == /obj/structure/window)
				cost = 4
				delay = 2 SECONDS
			else if(the_rcd.window_type  == /obj/structure/window/reinforced)
				cost = 6
				delay = 2.5 SECONDS
			return rcd_result_with_memory(
				list("mode" = RCD_WINDOWGRILLE, "delay" = delay, "cost" = cost),
				src, RCD_MEMORY_WINDOWGRILLE,
			)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 2 SECONDS, "cost" = 20)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 2 SECONDS, "cost" = 20)
		if(RCD_FLOODLIGHT)
			return list("mode" = RCD_FLOODLIGHT, "delay" = 3 SECONDS, "cost" = 20)
		if(RCD_GIRDER)
			return list("mode" = RCD_GIRDER, "delay" = 1.3 SECONDS, "cost" = 8)
		if(RCD_FURNISHING)
			var/cost = 0
			var/delay = 0
			if(the_rcd.furnish_type == /obj/structure/chair || the_rcd.furnish_type == /obj/structure/chair/stool)
				cost = 4
				delay = 1 SECONDS
			else if(the_rcd.furnish_type == /obj/structure/chair/stool/bar)
				cost = 4
				delay = 0.5 SECONDS
			else if(the_rcd.furnish_type == /obj/structure/table)
				cost = 8
				delay = 2 SECONDS
			else if(the_rcd.furnish_type == /obj/structure/table/glass)
				cost = 8
				delay = 2 SECONDS
			else if(the_rcd.furnish_type == /obj/structure/rack)
				cost = 4
				delay = 2.5 SECONDS
			else if(the_rcd.furnish_type == /obj/structure/bed)
				cost = 8
				delay = 1.5 SECONDS
			if(cost == 0)
				return FALSE
			return list("mode" = RCD_FURNISHING, "delay" = cost, "cost" = delay)
	return FALSE

/// if you are updating this make to to update /turf/open/misc/rcd_act() too
/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			var/obj/structure/girder/girder = locate() in src
			if(girder)
				return girder.rcd_act(user, the_rcd, passed_mode)

			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_REFLECTOR)
			if(locate(/obj/structure/reflector) in src)
				return FALSE
			var/obj/structure/reflector/reflector_base = new(src)
			reflector_base.set_anchored(TRUE)
			return TRUE
		if(RCD_AIRLOCK)
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/window))
				if(!valid_build_direction(src, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "there's already a windoor!")
					return FALSE
				for(var/obj/machinery/door/door in src)
					if(!istype(door, /obj/machinery/door/airlock))
						continue
					balloon_alert(user, "there's already a door!")
					return FALSE
				//create the assembly and let it finish itself
				var/obj/structure/windoor_assembly/assembly = new /obj/structure/windoor_assembly(src, user.dir)
				assembly.secure = ispath(the_rcd.airlock_type, /obj/machinery/door/window/brigdoor)
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
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/airlock/glass))
				assembly.glass = TRUE
				assembly.glass_type = the_rcd.airlock_type
			else
				assembly.airlock_type = the_rcd.airlock_type
			assembly.electronics = the_rcd.airlock_electronics.create_copy(assembly)
			assembly.finish_door()
			return TRUE
		if(RCD_DECONSTRUCT)
			if(rcd_proof)
				balloon_alert(user, "it's too thick!")
				return FALSE
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			return TRUE
		if(RCD_WINDOWGRILLE)
			//check if we are building a window
			var/obj/structure/window/window_path = the_rcd.window_type
			if(!ispath(window_path))
				CRASH("Invalid window path type in RCD: [window_path]")

			//allow directional windows to be built without grills
			if(!initial(window_path.fulltile))
				if(!valid_build_direction(src, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "window already here!")
					return FALSE
				var/obj/structure/window/WD = new the_rcd.window_type(src, user.dir)
				WD.set_anchored(TRUE)
				return TRUE

			//build grills to deal with full tile windows
			if(locate(/obj/structure/grille) in src)
				return FALSE
			var/obj/structure/grille/new_grille = new(src)
			new_grille.set_anchored(TRUE)
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/new_machine = new(src)
			new_machine.state = 2
			new_machine.icon_state = "box_1"
			new_machine.set_anchored(TRUE)
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/new_computer = new(src)
			new_computer.set_anchored(TRUE)
			new_computer.state = 1
			new_computer.setDir(the_rcd.computer_dir)
			return TRUE
		if(RCD_FLOODLIGHT)
			if(locate(/obj/structure/floodlight_frame) in src)
				return FALSE
			var/obj/structure/floodlight_frame/new_floodlight = new(src)
			new_floodlight.name = "secured [new_floodlight.name]"
			new_floodlight.desc = "A bare metal frame that looks like a floodlight. Requires a light tube to complete."
			new_floodlight.icon_state = "floodlight_c3"
			new_floodlight.state = FLOODLIGHT_NEEDS_LIGHTS
			return TRUE
		if(RCD_GIRDER)
			if(locate(/obj/structure/girder) in src)
				return FALSE
			new /obj/structure/girder(src)
			return TRUE
		if(RCD_FURNISHING)
			if(locate(the_rcd.furnish_type) in src)
				return FALSE
			var/atom/new_furnish = new the_rcd.furnish_type(src)
			new_furnish.setDir(user.dir)
			return TRUE
	return FALSE

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
		tile.set_mats_per_unit(custom_materials, 1)
