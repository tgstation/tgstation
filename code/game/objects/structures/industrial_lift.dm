
//Booleans in arguments are confusing, so I made them defines.
#define LOCKED 1
#define UNLOCKED 0

///Collect and command
/datum/lift_master
	var/list/lift_platforms
	var/list/ignored_smashthroughs = list(	//Typepath list of what to ignore smashing through, controls all lifts. Could be admemery?
		/obj/machinery/power/supermatter_crystal,
		/obj/structure/holosign
	)

/datum/lift_master/New(obj/structure/industrial_lift/lift_platform)
	Rebuild_lift_plaform(lift_platform)
	ignored_smashthroughs = typecacheof(ignored_smashthroughs)

/datum/lift_master/Destroy()
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		lift_platform.lift_master_datum = null
	lift_platforms = null
	return ..()


/datum/lift_master/proc/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	if(new_lift_platform in lift_platforms)
		return
	new_lift_platform.lift_master_datum = src
	LAZYADD(lift_platforms, new_lift_platform)
	RegisterSignal(new_lift_platform, COMSIG_PARENT_QDELETING, .proc/remove_lift_platforms)

/datum/lift_master/proc/remove_lift_platforms(obj/structure/industrial_lift/old_lift_platform)
	SIGNAL_HANDLER

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
	set_controls(UNLOCKED)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/MoveLiftHorizontal(going, z, gliding_amount = 8)
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
					lift_platform?.travel(going, gliding_amount)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
	else
		//Go along the X axis from max to min, from right to left
		for(var/x in max_x to min_x step -1)
			if( going & NORTH )
				//Go along the Y axis from max to min, from up to down
				for(var/y in max_y to min_y step -1)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
			else
				//Go along the Y axis from min to max, from down to up
				for(var/y in min_y to max_y)
					var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
					lift_platform?.travel(going, gliding_amount)
	set_controls(UNLOCKED)

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	for(var/l in lift_platforms)
		var/obj/structure/industrial_lift/lift_platform = l
		var/turf/T = get_step_multiz(lift_platform, check_dir)
		if(!T)//the edges of multi-z maps
			return FALSE
		if(check_dir == UP && !istype(T, /turf/open/openspace)) // We don't want to go through the ceiling!
			return FALSE
		if(check_dir == DOWN && !istype(get_turf(lift_platform), /turf/open/openspace)) // No going through the floor!
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
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 50)
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

/obj/structure/industrial_lift/Initialize(mapload)
	. = ..()
	GLOB.lifts.Add(src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED =.proc/UncrossedRemoveItemFromLift,
		COMSIG_ATOM_ENTERED = .proc/AddItemOnLift,
		COMSIG_ATOM_CREATED = .proc/AddItemOnLift,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	RegisterSignal(src, COMSIG_MOVABLE_BUMP, .proc/GracefullyBreak)

	if(!lift_master_datum)
		lift_master_datum = new(src)


/obj/structure/industrial_lift/proc/UncrossedRemoveItemFromLift(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	RemoveItemFromLift(gone)

/obj/structure/industrial_lift/proc/RemoveItemFromLift(atom/movable/potential_rider)
	SIGNAL_HANDLER
	if(!(potential_rider in lift_load))
		return
	if(isliving(potential_rider) && HAS_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED))
		REMOVE_TRAIT(potential_rider, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)		
	LAZYREMOVE(lift_load, potential_rider)
	UnregisterSignal(potential_rider, COMSIG_PARENT_QDELETING)

/obj/structure/industrial_lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(istype(AM, /obj/structure/fluff/tram_rail) || AM.invisibility == INVISIBILITY_ABSTRACT) //prevents the tram from stealing things like landmarks
		return
	if(AM in lift_load)
		return
	if(isliving(AM) && !HAS_TRAIT(AM, TRAIT_CANNOT_BE_UNBUCKLED))
		ADD_TRAIT(AM, TRAIT_CANNOT_BE_UNBUCKLED, BUCKLED_TRAIT)		
	LAZYADD(lift_load, AM)
	RegisterSignal(AM, COMSIG_PARENT_QDELETING, .proc/RemoveItemFromLift)

/**
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * bumped_atom - The atom this tram bumped into
 */
/obj/structure/industrial_lift/proc/GracefullyBreak(atom/bumped_atom)
	SIGNAL_HANDLER

	if(istype(bumped_atom, /obj/machinery/field))
		return

	bumped_atom.visible_message(span_userdanger("[src] crashes into the field violently!"))
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_master_datum.lift_platforms)
		tram_part.travel_distance = 0
		tram_part.set_travelling(FALSE)
		if(prob(15) || locate(/mob/living) in tram_part.lift_load) //always go boom on people on the track
			explosion(tram_part, devastation_range = rand(0, 1), heavy_impact_range = 2, light_impact_range = 3) //50% chance of gib
		qdel(tram_part)

/obj/structure/industrial_lift/proc/lift_platform_expansion(datum/lift_master/lift_master_datum)
	. = list()
	for(var/direction in GLOB.cardinals)
		var/obj/structure/industrial_lift/neighbor = locate() in get_step(src, direction)
		if(!neighbor)
			continue
		. += neighbor

/obj/structure/industrial_lift/proc/travel(going, gliding_amount = 8)
	var/list/things_to_move = LAZYCOPY(lift_load)
	var/turf/destination
	if(!isturf(going))
		destination = get_step_multiz(src, going)
	else
		destination = going
	///handles any special interactions objects could have with the lift/tram, handled on the item itself	
	SEND_SIGNAL(destination, COMSIG_TURF_INDUSTRIAL_LIFT_ENTER, things_to_move)

	if(istype(destination, /turf/closed/wall))
		var/turf/closed/wall/C = destination
		do_sparks(2, FALSE, C)
		C.dismantle_wall(devastated = TRUE)
		for(var/mob/M in urange(8, src))
			shake_camera(M, 2, 3)
		playsound(C, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	if(going == DOWN)
		for(var/mob/living/crushed in destination.contents)
			to_chat(crushed, span_userdanger("You are crushed by [src]!"))
			crushed.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.

	else if(going != UP) //can't really crush something upwards
		var/atom/throw_target = get_edge_target_turf(src, turn(going, pick(45, -45))) //finds a spot to throw the victim at for daring to be hit by a tram
		for(var/obj/structure/victim_structure in destination.contents)
			if(QDELETED(victim_structure))
				continue
			if(!is_type_in_typecache(victim_structure, lift_master_datum.ignored_smashthroughs) && victim_structure.layer >= LOW_OBJ_LAYER)
				if(victim_structure.anchored && initial(victim_structure.anchored) == TRUE)
					visible_message(span_danger("[src] smashes through [victim_structure]!"))
					victim_structure.deconstruct(FALSE)
				else
					visible_message(span_danger("[src] violently rams [victim_structure] out of the way!"))
					victim_structure.anchored = FALSE
					victim_structure.take_damage(rand(20, 25))
					victim_structure.throw_at(throw_target, 200, 4)
		for(var/obj/machinery/victim_machine in destination.contents)
			if(QDELETED(victim_machine))
				continue
			if(is_type_in_typecache(victim_machine, lift_master_datum.ignored_smashthroughs))
				continue
			if(istype(victim_machine, /obj/machinery/field)) //graceful break handles this scenario
				continue
			if(victim_machine.layer >= LOW_OBJ_LAYER) //avoids stuff that is probably flush with the ground
				playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
				visible_message(span_danger("[src] smashes through [victim_machine]!"))
				qdel(victim_machine)

		for(var/mob/living/collided in destination.contents)
			if(is_type_in_typecache(collided, lift_master_datum.ignored_smashthroughs))
				continue
			to_chat(collided, span_userdanger("[src] collides into you!"))
			playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
			var/damage = rand(5, 10)
			collided.apply_damage(2 * damage, BRUTE, BODY_ZONE_HEAD)
			collided.apply_damage(2 * damage, BRUTE, BODY_ZONE_CHEST)
			collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG)
			collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG)
			collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM)
			collided.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM)

			if(QDELETED(collided)) //in case it was a mob that dels on death
				continue
			var/turf/T = get_turf(src)
			T.add_mob_blood(collided)

			collided.throw_at()
			//if going EAST, will turn to the NORTHEAST or SOUTHEAST and throw the ran over guy away
			var/datum/callback/land_slam = new(collided, /mob/living/.proc/tram_slam_land)
			collided.throw_at(throw_target, 200, 4, callback = land_slam)

	set_glide_size(gliding_amount)
	forceMove(destination)
	for(var/atom/movable/thing as anything in things_to_move)
		thing.set_glide_size(gliding_amount) //matches the glide size of the moving platform to stop them from jittering on it.
		thing.forceMove(destination)

/obj/structure/industrial_lift/proc/use(mob/living/user)
	if(!isliving(user) || !in_range(src, user) || user.combat_mode)
		return

	var/list/tool_list = list()
	if(lift_master_datum.Check_lift_move(UP))
		tool_list["Up"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	if(lift_master_datum.Check_lift_move(DOWN))
		tool_list["Down"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
	if(!length(tool_list))
		to_chat(user, span_warning("[src] doesn't seem to able to move anywhere!"))
		add_fingerprint(user)
		return
	if(controls_locked)
		to_chat(user, span_warning("[src] has its controls locked! It must already be trying to do something!"))
		add_fingerprint(user)
		return
	var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user, src.loc), require_near = TRUE, tooltips = TRUE)
	if(!isliving(user) || !in_range(src, user) || user.combat_mode)
		return //nice try
	switch(result)
		if("Up")
			// We have to make sure that they don't do illegal actions by not having their radial menu refresh from someone else moving the lift.
			if(!lift_master_datum.Check_lift_move(UP))
				to_chat(user, span_warning("[src] doesn't seem to able to move up!"))
				add_fingerprint(user)
				return
			lift_master_datum.MoveLift(UP, user)
			show_fluff_message(TRUE, user)
			use(user)
		if("Down")
			if(!lift_master_datum.Check_lift_move(DOWN))
				to_chat(user, span_warning("[src] doesn't seem to able to move down!"))
				add_fingerprint(user)
				return
			lift_master_datum.MoveLift(DOWN, user)
			show_fluff_message(FALSE, user)
			use(user)
		if("Cancel")
			return
	add_fingerprint(user)

/**
 * Proc to ensure that the radial menu closes when it should.
 * Arguments:
 * * user - The person that opened the menu.
 * * starting_loc - The location of the lift when the menu was opened, used to prevent the menu from being interacted with after the lift was moved by someone else.
 *
 * Returns:
 * * boolean, FALSE if the menu should be closed, TRUE if the menu is clear to stay opened.
 */
/obj/structure/industrial_lift/proc/check_menu(mob/user, starting_loc)
	if(user.incapacitated() || !user.Adjacent(src) || starting_loc != src.loc)
		return FALSE
	return TRUE

/obj/structure/industrial_lift/attack_hand(mob/user, list/modifiers)
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

/obj/structure/industrial_lift/attack_paw(mob/user, list/modifiers)
	return use(user)

/obj/structure/industrial_lift/attackby(obj/item/W, mob/user, params)
	return use(user)

/obj/structure/industrial_lift/attack_robot(mob/living/silicon/robot/R)
	if(R.Adjacent(src))
		return use(R)

/**
 * Shows a message indicating that the lift has moved up or down.
 * Arguments:
 * * going_up - Boolean on whether or not we're going up, to adjust the message appropriately.
 * * user - The mob that caused the lift to move, for the visible message.
 */
/obj/structure/industrial_lift/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message(span_notice("[user] moves the lift upwards."), span_notice("You move the lift upwards."))
	else
		user.visible_message(span_notice("[user] moves the lift downwards."), span_notice("You move the lift downwards."))

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
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Set by the tram control console in late initialize
	var/travelling = FALSE
	var/travel_distance = 0
	/// For finding the landmark initially - should be the exact same as the landmark's destination id.
	var/initial_id = "middle_part"
	var/obj/effect/landmark/tram/from_where
	var/travel_direction

GLOBAL_DATUM(central_tram, /obj/structure/industrial_lift/tram/central)

/obj/structure/industrial_lift/tram/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/industrial_lift/tram/central//that's a surprise tool that can help us later

/obj/structure/industrial_lift/tram/central/Initialize(mapload)
	if(GLOB.central_tram)
		return INITIALIZE_HINT_QDEL

	. = ..()

	SStramprocess.can_fire = TRUE
	GLOB.central_tram = src

/obj/structure/industrial_lift/tram/central/Destroy()
	GLOB.central_tram = null
	return ..()

/obj/structure/industrial_lift/tram/LateInitialize()
	. = ..()
	find_our_location()


/**
 * Finds the location of the tram
 *
 * The initial_id is assumed to the be the landmark the tram is built on in the map
 * and where the tram will set itself to be on roundstart.
 * The central tram piece goes further into this by actually checking the contents of the turf its on
 * for a tram landmark when it docks anywhere. This assures the tram actually knows where it is after docking,
 * even in the worst cast scenario.
 */
/obj/structure/industrial_lift/tram/proc/find_our_location()
	for(var/obj/effect/landmark/tram/our_location in GLOB.landmarks_list)
		if(our_location.destination_id == initial_id)
			from_where = our_location
			break

/obj/structure/industrial_lift/tram/proc/set_travelling(travelling)
	if (src.travelling == travelling)
		return

	src.travelling = travelling
	SEND_SIGNAL(src, COMSIG_TRAM_SET_TRAVELLING, travelling)

/obj/structure/industrial_lift/tram/use(mob/user) //dont click the floor dingus we use computers now
	return

/obj/structure/industrial_lift/tram/process(delta_time)
	if(!travel_distance)
		addtimer(CALLBACK(src, .proc/unlock_controls), 3 SECONDS)
		return PROCESS_KILL
	else
		travel_distance--
		lift_master_datum.MoveLiftHorizontal(travel_direction, z, DELAY_TO_GLIDE_SIZE(SStramprocess.wait))

/**
 * Handles moving the tram
 *
 * Tells the individual tram parts where to actually go and has an extra safety check
 * incase multiple inputs get through, preventing conflicting directions and the tram
 * literally ripping itself apart. The proc handles the first move before the subsystem
 * takes over to keep moving it in process()
 */
/obj/structure/industrial_lift/tram/proc/tram_travel(obj/effect/landmark/tram/to_where)
	if(to_where == from_where)
		return

	visible_message(span_notice("[src] has been called to the [to_where]!"))

	lift_master_datum.set_controls(LOCKED)
	travel_direction = get_dir(from_where, to_where)
	travel_distance = get_dist(from_where, to_where)
	//first movement is immediate
	for(var/obj/structure/industrial_lift/tram/other_tram_part as anything in lift_master_datum.lift_platforms) //only thing everyone needs to know is the new location.
		if(other_tram_part.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo locked controls, though, as that will resolve itself
		SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, from_where, to_where)
		other_tram_part.set_travelling(TRUE)
		other_tram_part.from_where = to_where
	lift_master_datum.MoveLiftHorizontal(travel_direction, z, DELAY_TO_GLIDE_SIZE(SStramprocess.wait))
	travel_distance--

	START_PROCESSING(SStramprocess, src)

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/obj/structure/industrial_lift/tram/proc/unlock_controls()
	visible_message(span_notice("[src]'s controls are now unlocked."))
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_master_datum.lift_platforms) //only thing everyone needs to know is the new location.
		tram_part.set_travelling(FALSE)
		lift_master_datum.set_controls(UNLOCKED)

GLOBAL_LIST_EMPTY(tram_landmarks)

/obj/effect/landmark/tram
	name = "tram destination" //the tram buttons will mention this.
	icon_state = "tram"
	/// The ID of that particular destination.
	var/destination_id
	/// Icons for the tgui console to list out for what is at this location
	var/list/tgui_icons = list()

/obj/effect/landmark/tram/Initialize(mapload)
	. = ..()
	GLOB.tram_landmarks += src

/obj/effect/landmark/tram/Destroy()
	GLOB.tram_landmarks -= src
	return ..()


/obj/effect/landmark/tram/left_part
	name = "West Wing"
	destination_id = "left_part"
	tgui_icons = list("Arrivals" = "plane-arrival", "Command" = "bullhorn", "Security" = "gavel")

/obj/effect/landmark/tram/middle_part
	name = "Central Wing"
	destination_id = "middle_part"
	tgui_icons = list("Service" = "cocktail", "Medical" = "plus", "Engineering" = "wrench")

/obj/effect/landmark/tram/right_part
	name = "East Wing"
	destination_id = "right_part"
	tgui_icons = list("Departures" = "plane-departure", "Cargo" = "box", "Science" = "flask")
