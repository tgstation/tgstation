
//Booleans in arguments are confusing, so I made them defines.
#define LOCKED 1
#define UNLOCKED 0

///Collect and command
/datum/lift_master
	var/list/lift_platforms

	///If initialized, the platform will store gas mixtures it goes over, replacing them with a copy of this. It restores them when leaving.
	var/datum/gas_mixture/tram_mixture
	///assoc list for above, turf to what that turf's gas mix was.
	var/list/stored_gases = list()

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

/**
 * Updates the air on the tram only if the tram has a special gas mixture.
 * Spots that are no longer on the tram get their old gas mix back from the first loop.
 * Spots that are now on the tram get their gas mix stored and replaced by the lift master's gas mix.
 */
/datum/lift_master/proc/update_lift_atmos()
	for(var/lt in stored_gases)
		var/turf/open/lift_turf = lt
		if(!isopenturf(lift_turf) || locate(/obj/structure/industrial_lift) in lift_turf)
			continue
		//the tram is no longer here, we can restore it to the atmos it originally had
		var/datum/gas_mixture/old_air = stored_gases[lift_turf]
		stored_gases -= lift_turf
		lift_turf.copy_air(old_air)
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		var/turf/open/current_turf = get_turf(lift_platform)
		if(!isopenturf(current_turf) || stored_gases[current_turf]) //don't mess with wall atmos (??), or there already has the correct atmos
			continue
		//new location for the tram, we are going to save its air contents and override it with the tram atmos
		var/datum/gas_mixture/destination_air = current_turf.return_air()
		var/datum/gas_mixture/copied_destination_air = destination_air.copy()
		stored_gases[current_turf] = copied_destination_air
		current_turf.copy_air(tram_mixture)

/**
 * Moves the lift UP or DOWN, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 * Arguments:
 * going - UP or DOWN directions, where the lift should go. Keep in mind by this point checks of whether it should go up or down have already been done.
 * user - Whomever made the lift movement.
 */
/datum/lift_master/proc/MoveLift(going, mob/user)
	set_controls(LOCKED)
	for(var/p in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = p
		lift_platform.travel(going)
	if(tram_mixture)
		update_lift_atmos()
	set_controls(UNLOCKED)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/MoveLiftHorizontal(going, z)
	var/max_x = 1
	var/max_y = 1
	var/min_x = world.maxx
	var/min_y = world.maxy


	set_controls(LOCKED)
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
	if(tram_mixture)
		update_lift_atmos()
	set_controls(UNLOCKED)

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		var/turf/T = get_step_multiz(lift_platform, check_dir)
		if(!T)//the edges of multi-z maps
			return FALSE
		if(check_dir == DOWN && !istype(get_turf(lift_platform), /turf/open/openspace))
			return FALSE
	return TRUE

/**
 * Sets all lift parts's controls_locked variable. Used to prevent moving mid movement, or cooldowns.
 */
/datum/lift_master/proc/set_controls(state)
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		lift_platform.controls_locked = state

GLOBAL_LIST_EMPTY(lifts)
/obj/structure/industrial_lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	canSmoothWith = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN

	var/id = null //ONLY SET THIS TO ONE OF THE LIFT'S PARTS. THEY'RE CONNECTED! ONLY ONE NEEDS THE SIGNAL!
	var/pass_through_floors = FALSE //if true, the elevator works through floors
	var/controls_locked = FALSE //if true, the lift cannot be manually moved.
	var/list/atom/movable/lift_load //things to move
	var/datum/lift_master/lift_master_datum    //control from

/obj/structure/industrial_lift/New()
	GLOB.lifts.Add(src)
	..()

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
	if(going == DOWN)
		for(var/mob/living/crushed in destination.contents)
			to_chat(crushed, "<span class='userdanger'>You are crushed by [src]!</span>")
			crushed.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.
	else if(going != UP) //can't really crush something upwards
		for(var/mob/living/collided in destination.contents)
			to_chat(collided, "<span class='userdanger'>[src] collides into you!</span>")
			playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
			var/damage = rand(5,10)
			collided.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD)
			collided.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST)
			collided.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG)
			collided.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG)
			collided.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM)
			collided.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM)

			if(QDELETED(collided)) //in case it was a mob that dels on death
				continue
			var/turf/T = get_turf(src)
			T.add_mob_blood(collided)

			collided.throw_at()
			//if going EAST, will turn to the NORTHEAST or SOUTHEAST and throw the ran over guy away
			var/atom/throw_target = get_edge_target_turf(collided, turn(going, pick(45, -45)))
			collided.throw_at(throw_target, 200, 4)
	forceMove(destination)
	for(var/am in things2move)
		if(isnull(am))
			LAZYREMOVE(lift_load, am)//after enough use, one of these always ends up inside despite signals. when they show, we need to scrub them out.
			continue
		var/atom/movable/thing = am
		thing.forceMove(destination)

/obj/structure/industrial_lift/proc/use(mob/user, is_ghost=FALSE)
	if(is_ghost && !in_range(src, user))
		return

	var/list/tool_list = list()
	if(lift_master_datum.Check_lift_move(UP))
		tool_list["Up"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	if(lift_master_datum.Check_lift_move(DOWN))
		tool_list["Down"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
	if(!length(tool_list))
		to_chat(user, "<span class='warning'>[src] doesn't seem to able to move anywhere!</span>")
		add_fingerprint(user)
		return
	if(controls_locked)
		to_chat(user, "<span class='warning'>[src] has its controls locked! It must already be trying to do something!</span>")
		add_fingerprint(user)
		return
	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!is_ghost && !in_range(src, user))
		return  // nice try
	switch(result)
		if("Up")
			lift_master_datum.MoveLift(UP, user)
			show_fluff_message(TRUE, user)
			use(user)
		if("Down")
			lift_master_datum.MoveLift(DOWN, user)
			show_fluff_message(FALSE, user)
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

//ai probably shouldn't get to use lifts but they sure are great for admins to crush people with
/obj/structure/industrial_lift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	if(isAdminGhostAI(user))
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
		user.visible_message("<span class='notice'>[user] moves the lift upwards.</span>", "<span class='notice'>You move the lift upwards.</span>")
	else
		user.visible_message("<span class='notice'>[user] moves the lift downwards.</span>", "<span class='notice'>You move the lift downwards.</span>")

/obj/structure/industrial_lift/Destroy()
	GLOB.lifts.Remove(src)
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

/obj/structure/industrial_lift/tram
	name = "tram"
	desc = "A tram for traversing the station."
	icon = 'icons/turf/floors.dmi'
	icon_state = "titanium_yellow"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	//kind of a centerpiece of the station, so pretty tough to destroy
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 100, BIO = 80, RAD = 80, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/travelling = FALSE
	var/travel_distance = 0
	///for finding the landmark initially - should be the exact same as the landmark's destination id.
	var/initial_id = "middle_part"
	var/obj/effect/landmark/tram/from_where
	var/travel_direction
	var/time_inbetween_moves = 1

/obj/structure/industrial_lift/tram/use(mob/user, is_ghost=FALSE)
	if(is_ghost && !in_range(src, user))
		return

	if(controls_locked || travelling)
		to_chat(user, "<span class='warning'>[src] has its controls locked!</span>")
		add_fingerprint(user)
		return


	var/list/radial_buttons = list()
	var/list/button2landmark = list()

	if(!from_where) //only needs to grab landmark the first time
		for(var/obj/effect/landmark/tram/our_location in GLOB.landmarks_list)
			if(our_location.destination_id == initial_id)
				from_where = our_location
				break
	for(var/obj/effect/landmark/tram/destination in GLOB.landmarks_list)
		if(destination == from_where)
			continue
		var/direction_to_destination = get_dir(from_where, destination)
		var/direction_text = uppertext(dir2text(direction_to_destination))
		//far left or far right tram destination have multiple in the left and right slot, so lets add this as SOUTH
		var/button_direction
		if(radial_buttons[direction_text])
			button_direction = "NORTH[direction_text]" //there is already something in this direction
		else
			button_direction = direction_text
		button2landmark[button_direction] = destination
		radial_buttons[button_direction] = image(icon = 'icons/effects/effects.dmi', icon_state = destination.destination_id, dir = direction_to_destination)
	if(!radial_buttons.len)
		return //nowhere to go
	var/result = show_radial_menu(user, src, radial_buttons, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = FALSE)
	if (!result || result == "Cancel" || !in_range(src, user))
		return  // cancelling or trying to be a dirty cheat
	add_fingerprint(user)
	if(controls_locked || travelling) // someone else started
		to_chat(user, "<span class='warning'>[src]'s controls are locked up! Someone else started the tram!</span>")
		return
	tram_travel(from_where, button2landmark[result])

/obj/structure/industrial_lift/tram/process(delta_time)
	if(!travel_distance)
		addtimer(CALLBACK(src, .proc/unlock_controls), 3 SECONDS)
		return PROCESS_KILL
	else
		check_tick
		travel_distance--
		lift_master_datum.MoveLiftHorizontal(travel_direction, z)

/obj/structure/industrial_lift/tram/proc/tram_travel(obj/effect/landmark/tram/from_where, obj/effect/landmark/tram/to_where)
	visible_message("<span class='notice'>[src] has been called to the [to_where]!</span")
	lift_master_datum.set_controls(LOCKED)
	for(var/lift in lift_master_datum.lift_platforms) //only thing everyone needs to know is the new location.
		var/obj/structure/industrial_lift/tram/other_tram_part = lift
		other_tram_part.travelling = TRUE
		other_tram_part.from_where = to_where
	travel_direction = get_dir(from_where, to_where)
	travel_distance = get_dist(from_where, to_where)
	//first movement is immediate
	lift_master_datum.MoveLiftHorizontal(travel_direction, z)
	travel_distance--

	START_PROCESSING(SStramprocess, src)

/obj/structure/industrial_lift/tram/proc/unlock_controls()
	visible_message("<span class='notice'>[src]'s controls are now unlocked.</span")
	for(var/lift in lift_master_datum.lift_platforms) //only thing everyone needs to know is the new location.
		var/obj/structure/industrial_lift/tram/other_tram_part = lift
		other_tram_part.travelling = FALSE
	lift_master_datum.set_controls(UNLOCKED)

/obj/effect/landmark/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"
	var/destination_id

/obj/effect/landmark/tram/left_part
	name = "west wing"
	destination_id = "left_part"

/obj/effect/landmark/tram/middle_part
	name = "central wing"
	destination_id = "middle_part"

/obj/effect/landmark/tram/right_part
	name = "east wing"
	destination_id = "right_part"
