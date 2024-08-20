/// How many people do we need per borer spawned
#define POP_PER_BORER 30

/datum/round_event_control/antagonist/solo/from_ghosts/cortical_borer
	name = "Cortical Borer Infestation"
	tags = list(TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_ALIEN)
	typepath = /datum/round_event/ghost_role/cortical_borer
	antag_flag = ROLE_CORTICAL_BORER
	track = EVENT_TRACK_MAJOR
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
	)
	required_enemies = 2
	weight = 5 // as rare as a natural blob
	min_players = 20
	max_occurrences = 1 //should only ever happen once
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A cortical borer has appeared on station. It will also attempt to produce eggs, and will attempt to gather willing hosts and learn chemicals through the blood."

/datum/round_event/ghost_role/cortical_borer
	announce_when = 400

/datum/round_event/ghost_role/cortical_borer/setup()
	announce_when = rand(announce_when, announce_when + 50)
	setup = TRUE

/datum/round_event/ghost_role/cortical_borer/announce(fake)
	priority_announce(
		"Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.",
		"Lifesign Alert",
		ANNOUNCER_ALIENS,
	)

/datum/round_event/ghost_role/cortical_borer/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Cortical Borers getting stuck in small networks.
			// See: Security, Virology
			if(length(temp_vent_parent.other_atmos_machines) > 20)
				vents += temp_vent

	if(!length(vents))
		message_admins("An event attempted to spawn a borer but no suitable vents were found. Shutting down.")
		return MAP_ERROR

	var/list/candidates = SSpolling.poll_ghost_candidates(
		role = ROLE_CORTICAL_BORER,
		ignore_category = POLL_IGNORE_CORTICAL_BORER,
		alert_pic = /mob/living/basic/cortical_borer,
	)

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/living_number = max(length(GLOB.player_list) / POP_PER_BORER, 1)
	var/choosing_number = min(length(candidates), living_number)

	for(var/repeating_code in 1 to choosing_number)
		var/mob/dead/observer/new_borer = pick(candidates)
		candidates -= new_borer
		var/turf/vent_turf = get_turf(pick(vents))
		var/mob/living/basic/cortical_borer/spawned_cb = new /mob/living/basic/cortical_borer(vent_turf)
		spawned_cb.ckey = new_borer.ckey
		spawned_cb.mind.add_antag_datum(/datum/antagonist/cortical_borer/hivemind)
		announce_to_ghosts(spawned_cb)
		message_admins("[ADMIN_LOOKUPFLW(spawned_cb)] has been made into a borer by an event.")
		log_game("STORYTELLER: [key_name(new_borer)] was spawned as a borer by the storyteller.")
		to_chat(spawned_cb, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))

/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer
	name = "Cortical Borer Infestation"
	antag_datum = /datum/antagonist/cortical_borer
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_flag = ROLE_CORTICAL_BORER
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 20
	minimum_players = 10
	/// List of on-station vents
	var/list/vents = list()

/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer/execute()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Borers getting stuck in small networks.
			// See: Security, Virology
			if(length(temp_vent_parent.other_atmos_machines) > 20)
				vents += temp_vent
	if(!length(vents))
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/cortical_borer/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/basic/cortical_borer/new_borer = new(vent.loc)
	new_borer.key = applicant.key
	new_borer.move_into_vent(vent)
	message_admins("[ADMIN_LOOKUPFLW(new_borer)] has been made into a borer by the midround ruleset.")
	log_game("DYNAMIC: [key_name(new_borer)] was spawned as a borer by the midround ruleset.")
	return new_borer

#undef POP_PER_BORER
