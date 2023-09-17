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
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
		if(RCD_REFLECTOR)
			return list("mode" = RCD_REFLECTOR, "delay" = 2 SECONDS, "cost" = 20)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 5 SECONDS, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 5 SECONDS, "cost" = 16)
		if(RCD_WINDOWGRILLE)
			return rcd_result_with_memory(
				list("mode" = RCD_WINDOWGRILLE, "delay" = 1 SECONDS, "cost" = 4),
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
			if(!cost)
				return FALSE
			return list("mode" = RCD_FURNISHING, "delay" = cost, "cost" = delay)
	return FALSE

/turf/open/misc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
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
					if(istype(door, /obj/machinery/door/window))
						continue
					balloon_alert(user, "there's already a door!")
					return FALSE
				var/obj/machinery/door/window/new_window = new the_rcd.airlock_type(src, user.dir, the_rcd.airlock_electronics?.unres_sides)
				if(the_rcd.airlock_electronics)
					new_window.name = the_rcd.airlock_electronics.passed_name || initial(new_window.name)
					if(the_rcd.airlock_electronics.one_access)
						new_window.req_one_access = the_rcd.airlock_electronics.accesses.Copy()
					else
						new_window.req_access = the_rcd.airlock_electronics.accesses.Copy()
				new_window.autoclose = TRUE
				new_window.update_appearance()
				return TRUE

			for(var/obj/machinery/door/door in src)
				if(door.sub_door)
					continue
				balloon_alert(user, "there's already a door!")
				return FALSE
			var/obj/machinery/door/airlock/new_airlock = new the_rcd.airlock_type(src)
			new_airlock.electronics = new /obj/item/electronics/airlock(new_airlock)
			if(the_rcd.airlock_electronics)
				new_airlock.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				new_airlock.electronics.one_access = the_rcd.airlock_electronics.one_access
				new_airlock.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
				new_airlock.electronics.passed_name = the_rcd.airlock_electronics.passed_name
				new_airlock.electronics.passed_cycle_id = the_rcd.airlock_electronics.passed_cycle_id
				new_airlock.electronics.shell = the_rcd.airlock_electronics.shell
			if(new_airlock.electronics.one_access)
				new_airlock.req_one_access = new_airlock.electronics.accesses
			else
				new_airlock.req_access = new_airlock.electronics.accesses
			if(new_airlock.electronics.unres_sides)
				new_airlock.unres_sides = new_airlock.electronics.unres_sides
				new_airlock.unres_sensor = TRUE
			if(new_airlock.electronics.passed_name)
				new_airlock.name = sanitize(new_airlock.electronics.passed_name)
			if(new_airlock.electronics.passed_cycle_id)
				new_airlock.closeOtherId = new_airlock.electronics.passed_cycle_id
				new_airlock.update_other_id()
			new_airlock.autoclose = TRUE
			new_airlock.update_appearance()
			return TRUE
		if(RCD_WINDOWGRILLE)
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
