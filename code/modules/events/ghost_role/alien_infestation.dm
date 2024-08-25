/datum/round_event_control/antagonist/solo/from_ghosts/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/antagonist/solo/ghost/alien_infestation
	weight = 5

	min_players = 35 //monkie edit: 10 to 35 (tg what the fuck)

	earliest_start = 45 MINUTES //monkie edit: 20 to 90
	//dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A xenomorph larva spawns on a random vent."

	maximum_antags = 1
	antag_flag = ROLE_ALIEN
	enemy_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
	)
	required_enemies = 5
	max_occurrences = 1
	prompted_picking = TRUE

/datum/round_event_control/antagonist/solo/from_ghosts/alien_infestation/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE) //MONKESTATION ADDITION: fake_check = FALSE
	. = ..()
	if(!.)
		return .

	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			return FALSE

/datum/round_event/antagonist/solo/ghost/alien_infestation
	announce_when = 400
	fakeable = TRUE


/datum/round_event/antagonist/solo/ghost/alien_infestation/setup()
	announce_when = rand(announce_when, announce_when + 50)
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()

	if(prob(50))
		antag_count++

	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client
	if(length(cliented_list))
		mass_adjust_antag_rep(cliented_list, 1)

	if(prompted_picking)
		candidates = SSpolling.poll_candidates(
			question = "Would you like to be a [cast_control.name]?",
			check_jobban = antag_flag,
			role = antag_flag,
			poll_time = 20 SECONDS,
			group = candidates,
			alert_pic = /mob/living/carbon/alien/larva,
			role_name_text = lowertext(cast_control.name),
			chat_text_border_icon = /mob/living/carbon/alien/larva
		)

	var/list/weighted_candidates = return_antag_rep_weight(candidates)

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return MAP_ERROR

	for(var/i in 1 to antag_count)
		if(!length(candidates))
			break

		var/client/mob_client = pick_n_take_weighted(weighted_candidates)
		var/mob/candidate = mob_client.mob
		if(candidate.client) //I hate this
			candidate.client.prefs.reset_antag_rep()
		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		var/obj/vent = pick_n_take(vents)
		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate.key
		new_xeno.move_into_vent(vent)

		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by an event.")
		new_xeno.log_message("was spawned as an alien by an event.", LOG_GAME)

	setup = TRUE //MONKESTATION ADDITION

/datum/round_event/antagonist/solo/ghost/alien_infestation/announce(fake)
	var/living_aliens = FALSE
	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			living_aliens = TRUE

	if(living_aliens || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)
