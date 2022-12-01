#define SHIP_RUIN (10 MINUTES)
#define SHIP_DELETE (10 MINUTES)
#define SHIP_VIEW_RANGE 4

/obj/structure/overmap/ship
	name = "overmap vessel"
	desc = "A spacefaring vessel."
	icon_state = "ship"
	base_icon_state = "ship" //Prefix of all the icons used by the ship. (ex. [base_icon_state]_moving)


	/**
	 * Template
	 */
	///The docking port of the linked shuttle
	var/obj/docking_port/mobile/voidcrew/shuttle
	///The map template the shuttle was spawned from, if it was indeed created from a template. CAN BE NULL (ex. custom-built ships).
	var/datum/map_template/shuttle/voidcrew/source_template

	/**
	 * Ship stuff
	 */
	///State of the shuttle: idle, flying, docking, or undocking
	var/state = OVERMAP_SHIP_IDLE
	///Name of the Ship with the faction appended to it
	var/display_name
	///How long until the ship will delete itself.
	var/deletion_timer

	/**
	 * Player stuff
	 */
	///Shipwide bank account
	// var/datum/bank_account/ship/ship_account

	///Short memo of the ship shown to new joins
	var/memo = ""
	///Manifest list of people on the ship
	var/list/manifest = list()
	///Assoc list of remaining open job slots (job = remaining slots)
	var/list/job_slots

	/**
	 * Faction stuff
	 */
	/// The prefix the shuttle currently possesses
	var/faction_prefix
	///Voidcrew-unique team we link everyone's mind to.
	var/datum/team/voidcrew/ship_team

	/**
	 * Movement stuff
	 */
	var/y_thrust = 0
	var/x_thrust = 0
	/**
	 * Stuff needed to render the map
	 */

	/// Name of the map
	var/map_name
	/// The actual map screen
	var/atom/movable/screen/map_view/cam_screen
	/// The background of the map, usually doesn't do anything, but this is here so ships can customize the background ig?
	var/atom/movable/screen/background/cam_background

/obj/structure/overmap/ship/Initialize(mapload)
	. = ..()
	ship_team = new()
	ship_team.name = faction_prefix

	display_name = "[faction_prefix] [name]"

	map_name = "overmap_[REF(src)]_map"

	cam_screen = new
	cam_screen.del_on_map_removal = FALSE
	cam_screen.generate_view(map_name)

	cam_background = new
	cam_background.del_on_map_removal = FALSE
	cam_background.assigned_map = map_name

	SSovermap.simulated_ships += src

/obj/structure/overmap/ship/proc/assign_source_template(datum/map_template/shuttle/voidcrew/template)
	if(source_template)
		CRASH("ship [type] already has a source template but [template.type] was trying to assign itself as the source template")
	source_template = template
	job_slots = template.assemble_job_slots()

/obj/structure/overmap/ship/Destroy()
	source_template = null
	shuttle?.intoTheSunset()
	shuttle = null
	SSovermap.simulated_ships -= src
	// QDEL_NULL(ship_account)
	manifest?.Cut()
	job_slots?.Cut()
	QDEL_NULL(ship_team)
	QDEL_NULL(cam_screen)
	QDEL_NULL(cam_background)
	return ..()

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

#undef SHIP_RUIN
#undef SHIP_DELETE
#undef SHIP_VIEW_RANGE
