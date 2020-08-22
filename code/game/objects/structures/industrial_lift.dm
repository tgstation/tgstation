///Collect and command
/datum/lift_master
	var/list/lift_platforms

/datum/lift_master/Destroy()
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		lift_platform.lift_master_datum = null
	lift_platforms = null
	return ..()

/datum/lift_master/New(obj/structure/industrial_lift/lift_platform)
	Rebuild_lift_plaform(lift_platform)

/datum/lift_master/proc/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	if(new_lift_platform in lift_platforms)
		return
	new_lift_platform.lift_master_datum = src
	LAZYADD(lift_platforms, new_lift_platform)
	RegisterSignal(new_lift_platform, COMSIG_PARENT_QDELETING, .proc/remove_lift_platforms)

/datum/lift_master/proc/remove_lift_platforms(obj/structure/industrial_lift/old_lift_platform)
	if(!(old_lift_platform in lift_platforms))
		return
	old_lift_platform.lift_master_datum = null
	LAZYREMOVE(lift_platforms, old_lift_platform)
	UnregisterSignal(old_lift_platform, COMSIG_PARENT_QDELETING)

///Collect all bordered platforms
/datum/lift_master/proc/Rebuild_lift_plaform(obj/structure/industrial_lift/base_lift_platform)
	add_lift_platforms(base_lift_platform)
	var/list/possible_expansions = list(base_lift_platform)
	while(possible_expansions.len)
		for(var/b in possible_expansions)
			var/obj/structure/industrial_lift/borderline = b
			var/list/result = borderline.lift_platform_expansion(src)
			if(length(result))
				for(var/p in result)
					if(lift_platforms.Find(p))
						continue
					var/obj/structure/industrial_lift/lift_platform = p
					add_lift_platforms(lift_platform)
					possible_expansions |= lift_platform
			possible_expansions -= borderline

///Move all platforms together
/datum/lift_master/proc/MoveLift(going, mob/user)
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		lift_platform.travel(going)

/datum/lift_master/proc/MoveLiftHorizontal(going, z)
	var/max_x = 1
	var/max_y = 1
	var/min_x = world.maxx
	var/min_y = world.maxy
	
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		max_x = max(max_x, lift_platform.x)
		max_y = max(max_y, lift_platform.y)
		min_x = min(min_x, lift_platform.x)
		min_y = min(min_y, lift_platform.y)
		
	//This must be safe way to border tile to tile move of bordered platforms, that excludes platform overlapping.
	if( going & WEST )
		//Go along the X axis from min to max, from left to right
		for(var/x in min_x to max_x)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y in max_y to min_y step -1)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform.travel(going)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform.travel(going)	
	else
		//Go along the X axis from max to min, from right to left
		for(var/x in max_x to min_x step -1)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y in max_y to min_y step -1)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform.travel(going)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform.travel(going)		

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	for(var/lift_platform in lift_platforms)
		var/turf/T = get_step_multiz(lift_platform, check_dir)
		if(!T)// || !isopenturf(T))
			return FALSE
	return TRUE

/obj/structure/industrial_lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	canSmoothWith = null
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN

	var/list/atom/movable/lift_load //things to move
	var/datum/lift_master/lift_master_datum    //control from

/obj/structure/industrial_lift/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/AddItemOnLift)
	RegisterSignal(loc, COMSIG_ATOM_CREATED, .proc/AddItemOnLift)//For atoms created on platform
	RegisterSignal(src, COMSIG_MOVABLE_UNCROSSED, .proc/RemoveItemFromLift)

	if(!lift_master_datum)
		lift_master_datum = new(src)

/obj/structure/industrial_lift/Move(atom/newloc, direct)
	UnregisterSignal(loc, COMSIG_ATOM_CREATED)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_CREATED, .proc/AddItemOnLift)//For atoms created on platform

/obj/structure/industrial_lift/proc/RemoveItemFromLift(datum/source, atom/movable/AM)
	if(!(AM in lift_load))
		return
	LAZYREMOVE(lift_load, AM)
	UnregisterSignal(AM, COMSIG_PARENT_QDELETING)

/obj/structure/industrial_lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	if(AM in lift_load)
		return
	LAZYADD(lift_load, AM)
	RegisterSignal(AM, COMSIG_PARENT_QDELETING, .proc/RemoveItemFromLift)

/obj/structure/industrial_lift/proc/lift_platform_expansion(datum/lift_master/lift_master_datum)
	. = list()
	for(var/direction in GLOB.cardinals)
		var/obj/structure/industrial_lift/neighbor = locate() in get_step(src, direction)
		if(!neighbor)
			continue
		. += neighbor

/obj/structure/industrial_lift/proc/travel(going)
	var/list/things2move = LAZYCOPY(lift_load)
	var/turf/destination
	if(!isturf(going))
		destination = get_step_multiz(src, going)
	else
		destination = going
	forceMove(destination)
	for(var/am in things2move)
		var/atom/movable/thing = am
		thing.forceMove(destination)

/obj/structure/industrial_lift/proc/use(mob/user, is_ghost=FALSE)
	if (is_ghost && !in_range(src, user))
		return

	var/static/list/tool_list = list(
		"Up" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"Down" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
		)

	var/turf/can_move_up = lift_master_datum.Check_lift_move(UP)
	var/turf/can_move_up_down = lift_master_datum.Check_lift_move(DOWN)

	if (!can_move_up && !can_move_up_down)
		to_chat(user, "<span class='warning'>[src] doesn't seem to able move anywhere!</span>")
		add_fingerprint(user)
		return

	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if (!is_ghost && !in_range(src, user))
		return  // nice try
	switch(result)
		if("Up")
			if(can_move_up)
				lift_master_datum.MoveLift(UP, user)
				show_fluff_message(TRUE, user)
				use(user)
			else
				to_chat(user, "<span class='warning'>[src] doesn't seem to able move up!</span>")
				use(user)
		if("Down")
			if(can_move_up_down)
				lift_master_datum.MoveLift(DOWN, user)
				show_fluff_message(FALSE, user)
				use(user)
			else
				to_chat(user, "<span class='warning'>[src] doesn't seem to able move down!</span>")
				use(user)
		if("Cancel")
			return
	
	add_fingerprint(user)

/obj/structure/industrial_lift/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/industrial_lift/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	use(user)

/obj/structure/industrial_lift/attack_paw(mob/user)
	return use(user)

/obj/structure/industrial_lift/attackby(obj/item/W, mob/user, params)
	return use(user)

/obj/structure/industrial_lift/attack_robot(mob/living/silicon/robot/R)
	if(R.Adjacent(src))
		return use(R)

/obj/structure/industrial_lift/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message("<span class='notice'>[user] move lift up.</span>", "<span class='notice'>Lift move up.</span>")
	else
		user.visible_message("<span class='notice'>[user] move lift down.</span>", "<span class='notice'>Lift move down.</span>")

/obj/structure/industrial_lift/Destroy()
	QDEL_NULL(lift_master_datum)
	var/list/border_lift_platforms = lift_platform_expansion()
	moveToNullspace()
	for(var/border_lift in border_lift_platforms)
		lift_master_datum = new(border_lift)
	return ..()

/obj/structure/industrial_lift/debug
	name = "transport platform"
	desc = "A lightweight platform. It moves in any direction, except up and down."
	color = "#5286b9ff"

/obj/structure/industrial_lift/debug/use(mob/user)
	if (!in_range(src, user))
		return
//NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST
	var/static/list/tool_list = list(
		"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
		"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
		"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
		"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
		"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
		"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST)
		)

	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = FALSE)
	if (!in_range(src, user))
		return  // nice try

	switch(result)
		if("NORTH")
			lift_master_datum.MoveLiftHorizontal(NORTH, z)
			use(user)
		if("NORTHEAST")
			lift_master_datum.MoveLiftHorizontal(NORTHEAST, z)
			use(user)
		if("EAST")
			lift_master_datum.MoveLiftHorizontal(EAST, z)
			use(user)
		if("SOUTHEAST")
			lift_master_datum.MoveLiftHorizontal(SOUTHEAST, z)
			use(user)
		if("SOUTH")
			lift_master_datum.MoveLiftHorizontal(SOUTH, z)
			use(user)
		if("SOUTHWEST")
			lift_master_datum.MoveLiftHorizontal(SOUTHWEST, z)
			use(user)
		if("WEST")
			lift_master_datum.MoveLiftHorizontal(WEST, z)
			use(user)
		if("NORTHWEST")
			lift_master_datum.MoveLiftHorizontal(NORTHWEST, z)
			use(user)
		if("Cancel")
			return

	add_fingerprint(user)
