/turf/open/floor
	//NOTE: Floor code has been refactored, many procs were removed and refactored
	//- you should use istype() if you want to find out whether a floor has a certain type
	//- floor_tile is now a path, and not a tile obj
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	baseturfs = /turf/open/floor/plating

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_OPEN_FLOOR, SMOOTH_GROUP_TURF_OPEN)

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	intact = TRUE
	var/broken = FALSE
	var/burnt = FALSE
	var/floor_tile = null //tile that this floor drops
	var/list/broken_states
	var/list/burnt_states

	tiled_dirt = TRUE


/turf/open/floor/Initialize(mapload)
	if (!broken_states)
		broken_states = string_list(list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5"))
	else
		broken_states = string_list(broken_states)
	if(burnt_states)
		burnt_states = string_list(burnt_states)
	if(!broken && broken_states && (icon_state in broken_states))
		broken = TRUE
	if(!burnt && burnt_states && (icon_state in burnt_states))
		burnt = TRUE
	. = ..()
	//This is so damaged or burnt tiles or platings don't get remembered as the default tile
	var/static/list/icons_to_ignore_at_floor_init = list("foam_plating", "plating","light_on","light_on_flicker1","light_on_flicker2",
					"light_on_clicker3","light_on_clicker4","light_on_clicker5",
					"light_on_broken","light_off","wall_thermite","grass", "sand",
					"asteroid","asteroid_dug",
					"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
					"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
					"basalt","basalt_dug",
					"basalt0","basalt1","basalt2","basalt3","basalt4",
					"basalt5","basalt6","basalt7","basalt8","basalt9","basalt10","basalt11","basalt12",
					"snow","snow_dug","ice",
					"snow0","snow1","snow2","snow3","snow4",
					"snow5","snow6","snow7","snow8","snow9","snow10","snow11","snow12",
					"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood",
					"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
					"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
					"ironsand12", "ironsand13", "ironsand14", "ironsand15")
	if(broken || burnt || (icon_state in icons_to_ignore_at_floor_init)) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
	if(mapload && prob(33))
		MakeDirty()
	if(is_station_level(z))
		GLOB.station_turfs += src


/turf/open/floor/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/open/floor/ex_act(severity, target)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return
	if(target != null)
		severity = 3

	switch(severity)
		if(1)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(2)
			switch(pick(1,2;75,3))
				if(1)
					if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
						ReplaceWithLattice()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		return 1

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/update_icon()
	. = ..()
	update_visuals()

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/turf/open/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/open/floor/burn_tile()
	if(broken || burnt)
		return
	if(LAZYLEN(burnt_states))
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/open/floor/proc/make_plating(force = FALSE)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

///For when the floor is placed under heavy load. Calls break_tile(), but exists to be overridden by floor types that should resist crushing force.
/turf/open/floor/proc/crush()
	break_tile()

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_icon = icon_regular_floor
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.icon_regular_floor = old_icon
	W.setDir(old_dir)
	W.update_icon()
	return W

/turf/open/floor/attackby(obj/item/object, mob/user, params)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return .
	if(intact && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
		return TRUE
	if(user.a_intent == INTENT_HARM && istype(object, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/sheets = object
		return sheets.on_attack_floor(user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(intact && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
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
			to_chat(user, "<span class='notice'>You remove the broken plating.</span>")
	else
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the floor tile.</span>")
		if(make_tile)
			spawn_tile()
	return make_plating(force_plating)

/turf/open/floor/proc/has_tile()
	return floor_tile

/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return
	new floor_tile(src)

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
			else if(prob(50) && (/turf/open/space in baseturfs))
				ReplaceWithLattice()
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
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 20, "cost" = 16)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			return list("mode" = RCD_WINDOWGRILLE, "delay" = 10, "cost" = 4)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
		if(RCD_FURNISHING)
			return list("mode" = RCD_FURNISHING, "delay" = the_rcd.furnish_delay, "cost" = the_rcd.furnish_cost)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a wall.</span>")
			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_AIRLOCK)
			for(var/obj/machinery/door/door in src)
				if(door.sub_door)
					continue
				to_chat(user, "<span class='notice'>There is another door here!</span>")
				return FALSE
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/window))
				to_chat(user, "<span class='notice'>You build a windoor.</span>")
				var/obj/machinery/door/window/new_window = new the_rcd.airlock_type(src, user.dir)
				if(the_rcd.airlock_electronics)
					new_window.req_access = the_rcd.airlock_electronics.accesses.Copy()
					new_window.req_one_access = the_rcd.airlock_electronics.one_access
					new_window.unres_sides = the_rcd.airlock_electronics.unres_sides
				new_window.autoclose = TRUE
				new_window.update_icon()
				return TRUE
			to_chat(user, "<span class='notice'>You build an airlock.</span>")
			var/obj/machinery/door/airlock/new_airlock = new the_rcd.airlock_type(src)
			new_airlock.electronics = new /obj/item/electronics/airlock(new_airlock)
			if(the_rcd.airlock_electronics)
				new_airlock.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				new_airlock.electronics.one_access = the_rcd.airlock_electronics.one_access
				new_airlock.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
			if(new_airlock.electronics.one_access)
				new_airlock.req_one_access = new_airlock.electronics.accesses
			else
				new_airlock.req_access = new_airlock.electronics.accesses
			if(new_airlock.electronics.unres_sides)
				new_airlock.unres_sides = new_airlock.electronics.unres_sides
			new_airlock.autoclose = TRUE
			new_airlock.update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You construct the grille.</span>")
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
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/open/floor/material/has_tile()
	return custom_materials.len

/turf/open/floor/material/spawn_tile()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(src, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
