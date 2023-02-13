/// Immovable rod random event.
/// The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
/datum/round_event_control/immovable_rod
	name = "Immovable Rod"
	typepath = /datum/round_event/immovable_rod
	min_players = 15
	max_occurrences = 5
	category = EVENT_CATEGORY_SPACE
	description = "The station passes through an immovable rod."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	admin_setup = /datum/event_admin_setup/immovable_rod

/datum/round_event/immovable_rod
	announce_when = 5
	/// Admins can pick a spot the rod will aim for.
	var/atom/special_target
	/// Admins can also force it to loop around forever, or at least until the RD gets their hands on it.
	var/force_looping = FALSE

/datum/round_event/immovable_rod/announce(fake)
	priority_announce("What the fuck was that?!", "General Alert")

/datum/round_event/immovable_rod/start()
	var/startside = pick(GLOB.cardinals)
	var/turf/end_turf = get_edge_target_turf(get_random_station_turf(), turn(startside, 180))
	var/turf/start_turf = spaceDebrisStartLoc(startside, end_turf.z)
	var/atom/rod = new /obj/effect/immovablerod(start_turf, end_turf, special_target, force_looping)
	announce_to_ghosts(rod)

/datum/event_admin_setup/immovable_rod
	/// Admins can pick a spot the rod will aim for.
	var/atom/special_target
	/// Admins can also force it to loop around forever, or at least until the RD gets their hands on it.
	var/force_looping = FALSE

/datum/event_admin_setup/immovable_rod/prompt_admins()
	var/aimed = tgui_alert(usr,"Aimed at current location?", "Sniperod", list("Yes", "No"))
	if(aimed == "Yes")
		special_target = get_turf(usr)
	var/looper = tgui_alert(usr,"Would you like this rod to force-loop across space z-levels?", "Loopy McLoopface", list("Yes", "No"))
	if(looper == "Yes")
		force_looping = TRUE
	message_admins("[key_name_admin(usr)] has aimed an immovable rod [force_looping ? "(forced looping)" : ""] at [AREACOORD(special_target)].")
	log_admin("[key_name_admin(usr)] has aimed an immovable rod [force_looping ? "(forced looping)" : ""] at [AREACOORD(special_target)].")

/datum/event_admin_setup/immovable_rod/apply_to_event(datum/round_event/immovable_rod/event)
	event.special_target = special_target
	event.force_looping = force_looping
