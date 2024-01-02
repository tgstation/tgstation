///Threshold above which it uses the ship sprites instead of the shuttle sprites
#define SHIP_SIZE_THRESHOLD 150

#define SHIP_RUIN (10 MINUTES)
#define SHIP_DELETE (10 MINUTES)
#define SHIP_VIEW_RANGE 4

/obj/structure/overmap/ship
	name = "overmap vessel"
	desc = "A spacefaring vessel."
	icon_state = "ship"
	base_icon_state = "ship" //Prefix of all the icons used by the ship. (ex. [base_icon_state]_moving)

	/**
	 * Template and docking port.
	 */
	///The docking port of the linked shuttle
	var/obj/docking_port/mobile/voidcrew/shuttle
	///The map template the shuttle was spawned from, if it was indeed created from a template. CAN BE NULL (ex. custom-built ships).
	var/datum/map_template/shuttle/voidcrew/source_template

	/**
	 * Ship states and deletion.
	 */
	///State of the shuttle: idle, flying, docking, or undocking
	var/state = OVERMAP_SHIP_FLYING
	///Name of the Ship with the faction appended to it
	var/display_name
	///How long until the ship will delete itself.
	var/deletion_timer
	///Timer ID of the looping movement timer
	var/movement_callback_id

	/**
	 * Player-facing Ship stuff.
	 */
	///Shipwide bank account
	var/datum/bank_account/ship/ship_account
	///Voidcrew-unique team we link everyone's mind to.
	var/datum/team/voidcrew/ship_team

	///Boolean on whether players are allowed to latejoin into this ship, toggled by the job managing console.
	var/joining_allowed = TRUE
	///Name of the ship.
	var/map_name
	/// The prefix the shuttle currently possesses
	var/faction_prefix
	///Short memo of the ship, set by the crew, and shown to latejoiners.
	var/memo
	///ONLY USED FOR NON-SIMULATED SHIPS. The amount per burn that this ship accelerates
	var/acceleration_speed = 0.02
	///Cooldown until the ship can be renamed again
	COOLDOWN_DECLARE(rename_cooldown)
	/// Cooldown until you can change your faction again controlled by FACTION_COOLDOWN_TIME
	COOLDOWN_DECLARE(faction_cooldown)

	///Timer between job managing delays
	COOLDOWN_DECLARE(job_slot_adjustment_cooldown)
	///The overmap object the ship is docked to, if any
	var/obj/structure/overmap/docked
	///Manifest list of people on the ship
	var/list/manifest = list()
	///Assoc list of remaining open job slots (job = remaining slots)
	var/list/job_slots

	/**
	 * Movement stuff
	 */
	var/y_thrust = 0
	var/x_thrust = 0
		///Max possible speed (1 tile per second)
	var/static/max_speed = 1/(1 SECONDS)
	///Minimum speed. Any lower is rounded down. (0.5 tiles per minute)
	var/static/min_speed = 1/(2 MINUTES)
	///The current speed in x/y direction in grid squares per minute
	var/list/speed[2]
	///Vessel estimated thrust
	var/est_thrust
	///Average fuel fullness percentage
	var/avg_fuel_amnt = 100

	///Vessel approximate mass
	var/mass



	/// Which docking port the ship is occupying
	var/dock_index
		///~~If we need to render a map for cameras and helms for this object~~ basically can you look at and use this as a ship or station
	var/render_map = TRUE
		/**
	 * Stuff needed to render the map
	 */
	/// The actual map screen
	var/atom/movable/screen/map_view/cam_screen
	/// The background of the map, usually doesn't do anything, but this is here so ships can customize the background ig?
	var/atom/movable/screen/background/cam_background

/obj/structure/overmap/ship/Initialize(mapload, datum/map_template/shuttle/voidcrew/template)
	. = ..()
	if(!template) //no template, don't load
		qdel(src)
		return FALSE
	src.source_template = template

	ship_team = new()
	ship_team.name = template.name
	faction_prefix = template.faction_prefix
	ship_team.faction_prefix = faction_prefix
	ship_team.ship = src

	//now build the job slots.
	job_slots = source_template.assemble_job_slots()

	//then the account, which relies on there having a job, as we set it to the captain's.
	ship_account = new(newname = ship_team.name, job = job_slots[1], player_account = FALSE)

	display_name = template.name
	update_ship_color()

	if(render_map)	// Initialize map objects
		map_name = "overmap_[REF(src)]_map"

		cam_screen = new
		cam_screen.name = "screen"
		cam_screen.assigned_map = map_name
		cam_screen.del_on_map_removal = FALSE
		cam_screen.screen_loc = "[map_name]:1,1"

		cam_background = new
		cam_background.assigned_map = map_name
		cam_background.del_on_map_removal = FALSE
		update_screen()

	SSovermap.simulated_ships += src

/obj/structure/overmap/ship/Destroy()
	source_template = null
	shuttle?.intoTheSunset()
	shuttle = null
	SSovermap.simulated_ships -= src
	QDEL_NULL(ship_account)
	manifest?.Cut()
	job_slots?.Cut()
	QDEL_NULL(ship_team)
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_background)
	return ..()

/obj/structure/overmap/ship/attack_ghost(mob/user)
	if(shuttle)
		user.forceMove(get_turf(shuttle))
		return TRUE
	else
		return

/**
  * Just double checks all the engines on the shuttle
  */
/obj/structure/overmap/ship/proc/refresh_engines()
	var/calculated_thrust
	for(var/obj/machinery/power/shuttle_engine/ship/E in shuttle.engine_list)
		if (QDELETED(E)) //Garant that we has no ghost engines.
			shuttle.engine_list -= E
			continue
		E.update_engine()
		if(E.enabled)
			calculated_thrust += E.engine_power
	est_thrust = calculated_thrust

/// Updates the screen for the helm console
/obj/structure/overmap/ship/proc/update_screen()
	var/list/visible_turfs = list()
	var/list/visible_things = view(SHIP_VIEW_RANGE, src)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.fill_rect(1, 1, size_x, size_y)

/**
  * Updates the ships icon to make it easier to distinguish between factions
  */
/obj/structure/overmap/ship/proc/update_ship_color()
	switch(faction_prefix)
		if(SYNDICATE_SHIP)
			color = "#F10303"
		if(NANOTRASEN_SHIP)
			color = "#115188"
		if(NEUTRAL_SHIP)
			color = "#DDDDDD"
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/// Resets the ships thrust back to zero
/obj/structure/overmap/ship/proc/reset_thrust()
	if (abs(x_thrust) > 1)
		x_thrust += (1 * ((x_thrust > 0) ? -1 : 1))
	else
		x_thrust = 0

	if (abs(y_thrust) > 1)
		y_thrust += (1 * ((y_thrust > 0) ? -1 : 1))
	else
		y_thrust = 0

/// Move the ship object
/obj/structure/overmap/ship/proc/try_move()
	var/x_dir = (x_thrust > 0) ? 1 : -1
	var/y_dir = (y_thrust > 0) ? 1 : -1
	if (!x_thrust)
		x_dir = 0
	if (!y_thrust)
		y_dir = 0

	Move(locate(x + x_dir, y + y_dir, z))

/// Apply thrust to the ship object
/obj/structure/overmap/ship/proc/apply_thrust(x = 0, y = 0)
	if (x_thrust == 0 && y_thrust == 0)
		addtimer(CALLBACK(src, PROC_REF(do_move)), 0.5 SECONDS)
	x_thrust += x
	y_thrust += y

/// Fires the ship move loop
/obj/structure/overmap/ship/proc/do_move()
	if (x_thrust == 0 && y_thrust == 0)
		return

	try_move()
	update_screen()
	addtimer(CALLBACK(src, PROC_REF(do_move)), (1 / calculate_thrust()) SECONDS)

/// Calculates the current thrust of the ship
/obj/structure/overmap/ship/proc/calculate_thrust()
	return sqrt((x_thrust ** 2) + (y_thrust ** 2))

/obj/structure/overmap/ship/newtonian_move(direction, instant, start_delay)
	return // we don't want ships to endlessly drift in space

/**
  * Bastardized version of GLOB.manifest.manifest_inject, but used per ship
  */
/obj/structure/overmap/ship/proc/manifest_inject(mob/living/carbon/human/H, datum/job/human_job)
	set waitfor = FALSE
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		manifest[H.real_name] = human_job
	register_crewmember(H)

/obj/structure/overmap/ship/proc/register_crewmember(mob/living/carbon/human/crewmate)
	ship_team.add_member(crewmate.mind)
	RegisterSignal(crewmate, COMSIG_LIVING_DEATH, PROC_REF(on_member_death))

	//set their ID to use our bank account
	var/obj/item/card/id/card = crewmate.wear_id
	if(!istype(card))
		return
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[crewmate.account_id]"]
	if(account)
		qdel(account) //delete the individual account.
		card.registered_account = ship_account
		ship_account.bank_cards += card

	crewmate.mind.wipe_memory() //clears ALL memories, but currently all they have is their old bank account.
	crewmate.mind.assigned_role.paycheck_department = ship_team.name

	//Adds a faction hud to a newplayer documentation in _HELPERS/game.dm
//	add_faction_hud(FACTION_HUD_GENERAL, faction_prefix, crewmate)

/**
 * ##destroy_ship
 *
 * Deletes the ship, if there's no humans on.
 */
/obj/structure/overmap/ship/proc/destroy_ship(force)
	if(!force && (length(shuttle.get_all_humans()) > 0))
		return
	message_admins("\[SHUTTLE]: [shuttle.name] has been deleted!")
	log_shuttle("[shuttle.name] has been deleted!")
	shuttle.jumpToNullSpace()
//	update_docked_bools() //voidcrew todo: ship functionality
	qdel(src)

/obj/structure/overmap/ship/proc/ship_announce(message, title, must_be_same_z_level = FALSE, sound)
	var/list/announce_targets = list()
	for(var/datum/mind/shipmate as anything in ship_team.members)
		var/mob/crewmate = shipmate.current
		if(!crewmate)
			continue
		if(must_be_same_z_level && crewmate.z != z)
			continue
		announce_targets += crewmate
	priority_announce(message, title, sound || 'sound/ai/default/attention.ogg', null, "[name] Announcement", announce_targets)

/**
 * Mob death/revive
 *
 * Handles when a mob is killed and revived, to check if a ship should be deleted or not.
 */
/obj/structure/overmap/ship/proc/on_member_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_member_revive)) //if they come back.

	if(!ship_team.is_active_team(src) && !deletion_timer)
		start_deletion_timer()

/obj/structure/overmap/ship/proc/on_member_revive(mob/living/target, gibbed)
	SIGNAL_HANDLER

	if(deletion_timer)
		end_deletion_timer()

	UnregisterSignal(target, COMSIG_LIVING_REVIVE)

/**
 * Start/end deletion timers
 *
 * Starts and ends the timers to delete the ship
 */
/obj/structure/overmap/ship/proc/start_deletion_timer()
	switch(state)
		if(OVERMAP_SHIP_FLYING, OVERMAP_SHIP_UNDOCKING, OVERMAP_SHIP_ACTING)
			message_admins("\[SHUTTLE]: [display_name] has been queued for deletion in [SHIP_DELETE / 600] minutes! [ADMIN_COORDJMP(shuttle.loc)]")
			deletion_timer = addtimer(CALLBACK(src, PROC_REF(destroy_ship)), SHIP_DELETE, (TIMER_STOPPABLE|TIMER_UNIQUE))
		if(OVERMAP_SHIP_IDLE, OVERMAP_SHIP_DOCKING)
			message_admins("\[SHUTTLE]: [display_name] has been queued for ruin conversion in [SHIP_RUIN / 600] minutes! [ADMIN_COORDJMP(shuttle.loc)]")
			deletion_timer = addtimer(CALLBACK(shuttle, TYPE_PROC_REF(/obj/docking_port/mobile/voidcrew/, mothball)), SHIP_RUIN, (TIMER_STOPPABLE|TIMER_UNIQUE))

/obj/structure/overmap/ship/proc/end_deletion_timer()
	deltimer(deletion_timer)
	deletion_timer = null



/**
  * Acts on the specified option. Used for docking.
  * * user - Mob that started the action
  * * object - Overmap object to act on
  */
/obj/structure/overmap/ship/proc/overmap_object_act(mob/user, obj/structure/overmap/object, obj/structure/overmap/ship/optional_partner)
	if(!is_still() || state != OVERMAP_SHIP_FLYING)
		to_chat(user, "<span class='warning'>Ship must be still to interact!</span>")
		return

	INVOKE_ASYNC(object, TYPE_PROC_REF(/obj/structure/overmap, ship_act), user, src, optional_partner)

/**
  * Docks the shuttle by requesting a port at the requested spot.
  * * to_dock - The [/obj/structure/overmap] to dock to.
  * * dock_to_use - The [/obj/docking_port/mobile] to dock to.
  */
/obj/structure/overmap/ship/proc/dock(obj/structure/overmap/to_dock, obj/docking_port/stationary/dock_to_use)
	refresh_engines()
	// Voidcrew Edit: removes throw equation "THROW" = FLOOR(est_thrust / 200, 1)
	//shuttle.movement_force = list("KNOCKDOWN" = FLOOR(est_thrust / 50, 1), "THROW" = 0)
	shuttle.request(dock_to_use)

	priority_announce("Beginning docking procedures. Completion in [(shuttle.callTime + 1 SECONDS)/10] seconds.", "Docking Announcement", sender_override = name)
	docked = to_dock //this wasnt getting updated at all before which is strange
	addtimer(CALLBACK(src, PROC_REF(complete_dock), WEAKREF(to_dock)), shuttle.callTime + 1 SECONDS)
	state = OVERMAP_SHIP_DOCKING
	return "Commencing docking..."

/**
  * Proc called after a shuttle is moved, used for checking a ship's location when it's moved manually (E.G. calling the mining shuttle via a console)
  */
/obj/structure/overmap/ship/proc/check_loc()
	var/docked_object = shuttle.current_ship
	if(docked_object == loc) //The docked object is correct, move along
		return TRUE
	if(state == OVERMAP_SHIP_DOCKING || state == OVERMAP_SHIP_UNDOCKING)
		return
	if(!istype(loc, /obj/structure/overmap) && is_reserved_level(shuttle)) //The object isn't currently docked, and doesn't think it is. This is correct.
		return TRUE
	if(!istype(loc, /obj/structure/overmap) && !docked_object) //The overmap object thinks it's docked to something, but it really isn't. Move to a random tile on the overmap
		forceMove(SSovermap.get_unused_overmap_square())
		state = OVERMAP_SHIP_FLYING
		update_screen()
		return FALSE
	if(isturf(loc) && docked_object) //The overmap object thinks it's NOT docked to something, but it actually is. Move to the correct place.
		forceMove(docked_object)
		state = OVERMAP_SHIP_IDLE
		decelerate(max_speed)
		update_screen()
		return FALSE
	return TRUE

/**
*	To properly fix the bug of two ships docking at the same time causing issues,
*	we need to keep track of whether or not a ship is requesting to dock at a
*	port IMMEDIATELY after the command is issued.
*	This also includes keeping track of when the ship is no longer there, upon which
*	the bools need to be set to false.
*	This function should be called whenever an action occurs that would remove a ship from the map
*/
/obj/structure/overmap/ship/proc/update_docked_bools()
	var/obj/structure/overmap/dynamic/dockable_place = docked
	if (!dockable_place)
		return
	if (dock_index == 1)
		dockable_place.first_dock_taken = FALSE
		dock_index = 0
	else if (dock_index == 2)
		dockable_place.second_dock_taken = FALSE
		dock_index = 0

/**
  * Undocks the shuttle by launching the shuttle with no destination (this causes it to remain in transit)
  */
/obj/structure/overmap/ship/proc/undock()
	if(!is_still()) //how the hell is it even moving (is the question I've asked multiple times) //fuck you past me this didn't help at all
		decelerate(max_speed)
	if(isturf(loc))
		check_loc()
		return "Ship not docked!"
	if(!shuttle)
		return "Shuttle not found!"
	update_docked_bools()
	docked = null
	shuttle.destination = null
	shuttle.mode = SHUTTLE_IGNITING
	shuttle.setTimer(shuttle.ignitionTime)
	priority_announce("Beginning undocking procedures. Completion in [(shuttle.ignitionTime + 1 SECONDS)/10] seconds.", "Docking Announcement", sender_override = name)
	addtimer(CALLBACK(src, PROC_REF(complete_dock)), shuttle.ignitionTime + 1 SECONDS)
	state = OVERMAP_SHIP_UNDOCKING
	return "Beginning undocking procedures..."

/**
  * Sets the ship, shuttle, and shuttle areas to a new name.
  */

/**
  * Called after the shuttle docks, and finishes the transfer to the new location.
  */
/obj/structure/overmap/ship/proc/complete_dock(datum/weakref/to_dock)
	var/old_loc = loc
	switch(state)
		if(OVERMAP_SHIP_DOCKING) //so that the shuttle is truly docked first
			if(shuttle.mode == SHUTTLE_CALL || shuttle.mode == SHUTTLE_IDLE)
				var/obj/structure/overmap/docking_target = to_dock?.resolve()
				if(!docking_target) //Panic, somehow the docking target is gone but the shuttle has likely docked somewhere, get it out quickly
					state = OVERMAP_SHIP_FLYING
					shuttle.enterTransit()
					return

				if(istype(docking_target, /obj/structure/overmap/ship)) //hardcoded and bad
					var/obj/structure/overmap/ship/S = docking_target
					S.shuttle.shuttle_areas |= shuttle.shuttle_areas
				forceMove(docking_target)
				state = OVERMAP_SHIP_IDLE
			else
				addtimer(CALLBACK(src, PROC_REF(complete_dock), to_dock), 1 SECONDS) //This should never happen, yet it does sometimes.
		if(OVERMAP_SHIP_UNDOCKING)
			if(!isturf(loc))
				if(istype(loc, /obj/structure/overmap/ship)) //Even more hardcoded, even more bad
					var/obj/structure/overmap/ship/S = loc
					S.shuttle.shuttle_areas -= shuttle.shuttle_areas
					adjust_speed(S.speed[1], S.speed[2])
				forceMove(get_turf(loc))
				if(istype(old_loc, /obj/structure/overmap/planet))
					var/obj/structure/overmap/planet/D = old_loc
					INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/structure/overmap/planet, unload_level))
				state = OVERMAP_SHIP_FLYING
				//if(repair_timer)
					//deltimer(repair_timer)
				//addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/overmap/ship, tick_autopilot)), 5 SECONDS) //TODO: Improve this SOMEHOW
	calculate_mass()
	update_screen()

/obj/structure/overmap/ship/proc/set_ship_name(new_name, ignore_cooldown = FALSE, bypass_same_name = FALSE)
	if(bypass_same_name == FALSE)
		if(!new_name || new_name == name)
			return
	if(!COOLDOWN_FINISHED(src, rename_cooldown))
		return
	if(name != initial(name))
		priority_announce("The [name] has been renamed to the [new_name].", "Docking Announcement", sender_override = display_name)
	message_admins("[key_name_admin(usr)] renamned vessel '[name]' to '[new_name]'")
	name = new_name
	shuttle.name = "[faction_prefix] [new_name]"
	display_name = "[faction_prefix] [name]"
	if(!ignore_cooldown)
		COOLDOWN_START(src, rename_cooldown, 5 MINUTES)
	for(var/area/shuttle_area as anything in shuttle.shuttle_areas)
//		shuttle_area.rename_area("[display_name] [initial(shuttle_area.name)]")
	return TRUE

/obj/structure/overmap/ship/proc/adjust_speed(n_x, n_y)
	var/offset = 1
	if(movement_callback_id)
		var/previous_time = 1 / MAGNITUDE(speed[1], speed[2])
		offset = timeleft(movement_callback_id) / previous_time
		deltimer(movement_callback_id)
		movement_callback_id = null //just in case

	speed[1] += n_x
	speed[2] += n_y

	update_icon_state()

	if(is_still() || QDELETED(src) || movement_callback_id)
		return

	var/timer = 1 / MAGNITUDE(speed[1], speed[2]) * offset
	movement_callback_id = addtimer(CALLBACK(src, PROC_REF(tick_move)), timer, TIMER_STOPPABLE)

/**
  * Called by /proc/adjust_speed(), this continually moves the ship according to it's speed
  */
/obj/structure/overmap/ship/proc/tick_move()
	if(is_still() || QDELETED(src))
		deltimer(movement_callback_id)
		movement_callback_id = null
		return
	var/turf/newloc = locate(x + SIGN(speed[1]), y + SIGN(speed[2]), z)
	Move(newloc)
	if(movement_callback_id)
		deltimer(movement_callback_id)

	//Queue another movement
	var/current_speed = MAGNITUDE(speed[1], speed[2])
	if(!current_speed)
		return

	var/timer = 1 / current_speed
	movement_callback_id = addtimer(CALLBACK(src, PROC_REF(tick_move)), timer, TIMER_STOPPABLE)
	update_screen()

/**
  * Returns whether or not the ship is moving in any direction.
  */
/obj/structure/overmap/ship/proc/is_still()
	return !speed[1] && !speed[2]

/**
  * Docks to an empty dynamic encounter. Used for intership interaction, structural modifications, and such
  * * user - The user that initiated the action
  */
/obj/structure/overmap/ship/proc/dock_in_empty_space(mob/user)
	var/obj/structure/overmap/planet/empty/E
	E = locate() in get_turf(src)
	if(!E)
		E = new(get_turf(src))
	if(E)
		return overmap_object_act(user, E)

/**
  * Calculates the mass based on the amount of turfs in the shuttle's areas
  */
/obj/structure/overmap/ship/proc/calculate_mass()
	. = 0
	var/list/areas = shuttle.shuttle_areas
	for(var/shuttleArea in areas)
		. += length(get_area_turfs(shuttleArea))
	mass = .
	update_icon_state()

/obj/structure/overmap/ship/update_icon_state()
	if(mass < SHIP_SIZE_THRESHOLD)
		base_icon_state = "shuttle"
	else
		base_icon_state = "ship"
	if(!is_still())
		icon_state = "[base_icon_state]_moving"
		dir = get_heading()
	else
		icon_state = base_icon_state
	return ..()

/**
  * Calculates the average fuel fullness of all engines.
  */
/obj/structure/overmap/ship/proc/calculate_avg_fuel()
	var/fuel_avg = 0
	var/engine_amnt = 0
	for(var/obj/machinery/power/shuttle_engine/ship/E in shuttle.engine_list)
		if(!E.enabled)
			continue
		fuel_avg += E.return_fuel() / E.return_fuel_cap()
		engine_amnt++
	if(!engine_amnt || !fuel_avg)
		avg_fuel_amnt = 0
		return
	avg_fuel_amnt = round(fuel_avg / engine_amnt * 100)

/**
  * Returns the total speed in all directions.
  *
  * The equation for acceleration is as follows:
  * 60 SECONDS / (1 / ([ship's speed] / ([ship's mass] * 100)))
  */
/obj/structure/overmap/ship/proc/get_speed()
	if(is_still())
		return 0
	return 60 SECONDS / (1 / MAGNITUDE(speed[1], speed[2])) //It's per minute, which is 60 seconds

/**
  * Returns the direction the ship is moving in terms of dirs
  */
/obj/structure/overmap/ship/proc/get_heading()
	var/direction = 0
	if(speed[1])
		if(speed[1] > 0)
			direction |= EAST
		else
			direction |= WEST
	if(speed[2])
		if(speed[2] > 0)
			direction |= NORTH
		else
			direction |= SOUTH
	return direction

/**
  * Returns the estimated time in deciseconds to the next tile at current speed, or approx. time until reaching the destination when on autopilot
  */
/obj/structure/overmap/ship/proc/get_eta()

	. += timeleft(movement_callback_id)
	if(!.)
		return "--:--"
	. /= 10 //they're in deciseconds
	return "[add_leading(num2text((. / 60) % 60), 2, "0")]:[add_leading(num2text(. % 60), 2, "0")]"

/**
  * Change the speed in a specified dir.
  * * direction - dir to accelerate in (NORTH, SOUTH, SOUTHEAST, etc.)
  * * acceleration - How much to accelerate by
  */
/obj/structure/overmap/ship/proc/accelerate(direction, acceleration)
	var/heading = get_heading()
	if(!(direction in GLOB.cardinals))
		acceleration *= 0.5 //Makes it so going diagonally isn't 2x as efficient
	if(heading && (direction & DIRFLIP(heading))) //This is so if you burn in the opposite direction you're moving, you can actually reach zero
		if(EWCOMPONENT(direction))
			acceleration = min(acceleration, abs(speed[1]))
		else
			acceleration = min(acceleration, abs(speed[2]))
	if(direction & EAST)
		adjust_speed(acceleration, 0)
	if(direction & WEST)
		adjust_speed(-acceleration, 0)
	if(direction & NORTH)
		adjust_speed(0, acceleration)
	if(direction & SOUTH)
		adjust_speed(0, -acceleration)

/**
  * Reduce the speed or stop in all directions.
  * * acceleration - How much to decelerate by
  */
/obj/structure/overmap/ship/proc/decelerate(acceleration)
	if(speed[1] && speed[2]) //another check to make sure that deceleration isn't 2x as fast when moving diagonally
		adjust_speed(-SIGN(speed[1]) * min(acceleration * 0.5, abs(speed[1])), -SIGN(speed[2]) * min(acceleration * 0.5, abs(speed[2])))
	else if(speed[1])
		adjust_speed(-SIGN(speed[1]) * min(acceleration, abs(speed[1])), 0)
	else if(speed[2])
		adjust_speed(0, -SIGN(speed[2]) * min(acceleration, abs(speed[2])))

/obj/structure/overmap/ship/Bump(atom/A)
/*
	if(istype(A, /turf/open/overmap/edge))
		handle_wraparound()
	..()
	*/

/**
  * Check if the ship is flying into the border of the overmap.
  */
/obj/structure/overmap/ship/proc/handle_wraparound()
	var/nx = x
	var/ny = y
	var/low_edge = 2
	var/high_edge = SSovermap.size - 1

	if((dir & WEST) && x == low_edge)
		nx = high_edge
	else if((dir & EAST) && x == high_edge)
		nx = low_edge
	if((dir & SOUTH)  && y == low_edge)
		ny = high_edge
	else if((dir & NORTH) && y == high_edge)
		ny = low_edge
	if((x == nx) && (y == ny))
		return //we're not flying off anywhere

	var/turf/T = locate(nx,ny,z)
	if(T)
		forceMove(T)

/**
 * Burns the engines in one direction, accelerating in that direction.
 * Unsimulated ships use the acceleration_speed var, simulated ships check eacch engine's thrust and fuel.
 * If no dir variable is provided, it decelerates the vessel.
 * * n_dir - The direction to move in
 */
/obj/structure/overmap/ship/proc/burn_engines(n_dir = null, percentage = 100)
	if(!n_dir)
		decelerate(acceleration_speed * (percentage / 100))
	else
		accelerate(n_dir, acceleration_speed * (percentage / 100))

#undef SHIP_SIZE_THRESHOLD

#undef SHIP_RUIN
#undef SHIP_DELETE
#undef SHIP_VIEW_RANGE
