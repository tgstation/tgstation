#define EMAGGED_METEOR_SHIELD_THRESHOLD_ONE 3
#define EMAGGED_METEOR_SHIELD_THRESHOLD_TWO 6
#define EMAGGED_METEOR_SHIELD_THRESHOLD_THREE 7
#define EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR 10

//Station Shield
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/station_shield
	name = "Station Shield"
	var/coverage_goal = 500
	requires_space = TRUE

/datum/station_goal/station_shield/get_report()
	return list(
		"<blockquote>The station is located in a zone full of space debris.",
		"We have a prototype shielding system you must deploy to reduce collision-related accidents.",
		"",
		"You can order the satellites and control systems at cargo.</blockquote>",
	).Join("\n")


/datum/station_goal/station_shield/on_report()
	//Unlock
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat_control]
	P.special_enabled = TRUE

/datum/station_goal/station_shield/check_completion()
	if(..())
		return TRUE
	if(get_coverage() >= coverage_goal)
		return TRUE
	return FALSE

/datum/station_goal/proc/get_coverage()
	var/list/coverage = list()
	for(var/obj/machinery/satellite/meteor_shield/A in GLOB.machines)
		if(!A.active || !is_station_level(A.z))
			continue
		coverage |= view(A.kill_range,A)
	return coverage.len

/obj/machinery/satellite/meteor_shield
	name = "\improper Meteor Shield Satellite"
	desc = "A meteor point-defense satellite."
	mode = "M-SHIELD"
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	/// amount of emagged active meteor shields
	var/static/emagged_active_meteor_shields = 0
	/// the highest amount of shields you've ever emagged
	var/static/highest_emagged_threshold_reached = 0
	/// the range a meteor shield sat can destroy meteors
	var/kill_range = 14

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in get_line(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/process()
	if(!active)
		return
	for(var/obj/effect/meteor/meteor_to_destroy in GLOB.meteor_list)
		if(meteor_to_destroy.z != z)
			continue
		if(get_dist(meteor_to_destroy, src) > kill_range)
			continue
		if(!(obj_flags & EMAGGED) && space_los(meteor_to_destroy))
			Beam(get_turf(meteor_to_destroy), icon_state="sat_beam", time = 5)
			if(meteor_to_destroy.shield_defense(src))
				qdel(meteor_to_destroy)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(!..(user))
		return FALSE
	if(obj_flags & EMAGGED)
		update_emagged_meteor_sat(user)

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(obj_flags & EMAGGED)
		//satellites that are destroying are not active, this will count down the number of emagged sats
		update_emagged_meteor_sat()

/obj/machinery/satellite/meteor_shield/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You access the satellite's debug mode, increasing the chance of meteor strikes."))
	if(active) //if we allowed inactive updates a sat could be worth -1 active meteor shields on first emag
		update_emagged_meteor_sat(user)

/obj/machinery/satellite/meteor_shield/proc/update_emagged_meteor_sat(mob/user)
	if(!active)
		change_meteor_chance(0.5)
		emagged_active_meteor_shields--
		if(user)
			balloon_alert(user, "meteor probability halved")
		return
	change_meteor_chance(2)
	emagged_active_meteor_shields++
	if(user)
		balloon_alert(user, "meteor probability doubled")
	if(emagged_active_meteor_shields > highest_emagged_threshold_reached)
		highest_emagged_threshold_reached = emagged_active_meteor_shields
		handle_new_emagged_shield_threshold()

/obj/machinery/satellite/meteor_shield/proc/handle_new_emagged_shield_threshold()
	switch(highest_emagged_threshold_reached)
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_ONE)
			say("Warning. Meteor strike probability entering dangerous ranges for more exotic meteors.")
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_TWO)
			say("Warning. Risk of dark matter congealment entering existent ranges. Further tampering will be reported.")
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_THREE)
			say("Warning. Further tampering has been reported.")
			priority_announce()
		if(EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR)
			say("Warning. Warning. Dark Matt-eor on course for station.")
			var/datum/round_event_control/dark_matteor/dark_matteor_event = locate() in SSevents.control
			if(!dark_matteor_event)
				CRASH("meteor shields tried to spawn a dark matteor, but there was no dark matteor event in SSevents.control?")
			INVOKE_ASYNC(dark_matteor_event, TYPE_PROC_REF(/datum/round_event_control, runEvent))

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	// Update the weight of all meteor events
	for(var/datum/round_event_control/meteor_wave/meteors in SSevents.control)
		meteors.weight *= mod
	for(var/datum/round_event_control/stray_meteor/stray_meteor in SSevents.control)
		stray_meteor.weight *= mod

#undef EMAGGED_METEOR_SHIELD_THRESHOLD_ONE
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_TWO
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_THREE
#undef EMAGGED_METEOR_SHIELD_THRESHOLD_FOUR
