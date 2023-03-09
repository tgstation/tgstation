/datum/round_event_control/pirates
	name = "Space Pirates"
	typepath = /datum/round_event/pirates
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_INVASION
	description = "The crew will either pay up, or face a pirate assault."
	admin_setup = list(/datum/event_admin_setup/listed_options/pirates)
	map_flags = EVENT_SPACE_ONLY

/datum/round_event_control/pirates/preRunEvent()
	if (!SSmapping.is_planetary())
		return EVENT_CANT_RUN
	return ..()

/datum/round_event/pirates
	///admin chosen pirate team
	var/datum/pirate_gang/chosen_gang

/datum/round_event/pirates/start()
	send_pirate_threat(chosen_gang)

/proc/send_pirate_threat(datum/pirate_gang/chosen_gang)
	if(!chosen_gang)
		chosen_gang = pick_n_take(GLOB.pirate_gangs)
	//set payoff
	var/payoff = 0
	var/datum/bank_account/account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(account)
		payoff = max(PAYOFF_MIN, FLOOR(account.account_balance * 0.80, 1000))
	var/datum/comm_message/threat = chosen_gang.generate_message(payoff)
	//send message
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())
	threat.answer_callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pirates_answered), threat, chosen_gang, payoff, world.time)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_pirates), threat, chosen_gang, FALSE), RESPONSE_MAX_TIME)
	SScommunications.send_message(threat, unique = TRUE)

/proc/pirates_answered(datum/comm_message/threat, datum/pirate_gang/chosen_gang, payoff, initial_send_time)
	if(world.time > initial_send_time + RESPONSE_MAX_TIME)
		priority_announce(chosen_gang.response_too_late ,sender_override = chosen_gang.ship_name)
		return
	if(threat?.answered)
		var/datum/bank_account/plundered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(plundered_account)
			if(plundered_account.adjust_money(-payoff))
				priority_announce(chosen_gang.response_received, sender_override = chosen_gang.ship_name)
			else
				priority_announce(chosen_gang.response_not_enough, sender_override = chosen_gang.ship_name)
				spawn_pirates(threat, chosen_gang, TRUE)

/proc/spawn_pirates(datum/comm_message/threat, datum/pirate_gang/chosen_gang, skip_answer_check)
	if(!skip_answer_check && threat?.answered == 1)
		return

	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for pirate crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/template_key = "pirate_[chosen_gang.ship_template_id]"
	var/datum/map_template/shuttle/pirate/ship = SSmapping.shuttle_templates[template_key]
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Pirate event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading pirate ship failed!")

	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/ghost_role/human/pirate/spawner in A)
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				var/mob/spawned_mob = spawner.create_from_ghost(our_candidate)
				candidates -= our_candidate
				notify_ghosts("The pirate ship has an object of interest: [spawned_mob]!", source = spawned_mob, action = NOTIFY_ORBIT, header="Pirates!")
			else
				notify_ghosts("The pirate ship has an object of interest: [spawner]!", source = spawner, action = NOTIFY_ORBIT, header="Pirate Spawn Here!")

	priority_announce("Unidentified armed ship detected near the station.")

/datum/event_admin_setup/listed_options/pirates
	input_text = "Select Pirate Gang"
	normal_run_option = "Random Pirate Gang"

/datum/event_admin_setup/listed_options/pirates/get_list()
	return subtypesof(/datum/pirate_gang)

/datum/event_admin_setup/listed_options/pirates/apply_to_event(datum/round_event/pirates/event)
	if(isnull(chosen))
		event.chosen_gang = null
	else
		event.chosen_gang = new chosen
