#define SHIP_RUIN (10 MINUTES)
#define SHIP_DELETE (10 MINUTES)

/obj/structure/overmap/ship
	name = "overmap vessel"
	desc = "A spacefaring vessel."
	icon_state = "ship"
	base_icon_state = "ship" //Prefix of all the icons used by the ship. (ex. [base_icon_state]_moving)


	/**
	 * Template
	 */
	///The docking port of the linked shuttle
	var/obj/docking_port/mobile/shuttle
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
	var/datum/bank_account/ship/ship_account
	///Short memo of the ship shown to new joins
	var/memo = ""
	///Manifest list of people on the ship
	var/list/manifest = list()
	///Assoc list of remaining open job slots (job = remaining slots)
	var/list/job_slots = list()

	/**
	 * Faction stuff
	 */
	/// The prefix the shuttle currently possesses
	var/faction_prefix
	///Voidcrew-unique team we link everyone's mind to.
	var/datum/team/voidcrew/ship_team

/obj/structure/overmap/ship/Initialize(mapload)
	. = ..()
	ship_team = new()
	ship_team.name = faction_prefix

	display_name = "[faction_prefix] [name]"

/**
  * Bastardized version of GLOB.manifest.manifest_inject, but used per ship
  *
  */
/obj/structure/overmap/ship/proc/manifest_inject(mob/living/carbon/human/H, datum/job/human_job)
	set waitfor = FALSE
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		manifest[H.real_name] = human_job
	register_crewmember(H)

/obj/structure/overmap/ship/proc/register_crewmember(mob/living/carbon/human/crewmate)
	ship_team.add_member(crewmate.mind)
	RegisterSignal(crewmate, COMSIG_LIVING_DEATH, .proc/on_member_death)
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


/**
 * Mob death/revive
 *
 * Handles when a mob is killed and revived, to check if a ship should be deleted or not.
 */
/obj/structure/overmap/ship/proc/on_member_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	RegisterSignal(target, COMSIG_LIVING_REVIVE, .proc/on_member_revive) //if they come back.

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
			deletion_timer = addtimer(CALLBACK(src, .proc/destroy_ship), SHIP_DELETE, (TIMER_STOPPABLE|TIMER_UNIQUE))
		if(OVERMAP_SHIP_IDLE, OVERMAP_SHIP_DOCKING)
			message_admins("\[SHUTTLE]: [display_name] has been queued for ruin conversion in [SHIP_RUIN / 600] minutes! [ADMIN_COORDJMP(shuttle.loc)]")
			deletion_timer = addtimer(CALLBACK(shuttle, /obj/docking_port/mobile/.proc/mothball), SHIP_RUIN, (TIMER_STOPPABLE|TIMER_UNIQUE))

/obj/structure/overmap/ship/proc/end_deletion_timer()
	deltimer(deletion_timer)
	deletion_timer = null

#undef SHIP_RUIN
#undef SHIP_DELETE

