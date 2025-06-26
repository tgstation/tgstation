/datum/dynamic_ruleset/midround
	repeatable = TRUE
	repeatable_weight_decrease = 2
	/// LIGHT_MIDROUND or HEAVY_MIDROUND - determines which pool it enters
	var/midround_type
	/// If the false alarm event can pick this ruleset to trigger, well, a false alarm
	var/false_alarm_able = FALSE

/**
 * Collect candidates handles getting the broad pool of players we want to pick from
 *
 * You can sleep in this - say, if you wanted to poll players.
 */
/datum/dynamic_ruleset/midround/proc/collect_candidates()
	return list()

/**
 * Called when the ruleset is selected for false alarm
 */
/datum/dynamic_ruleset/midround/proc/false_alarm()
	return

/datum/dynamic_ruleset/midround/spiders
	name = "Spiders"
	config_tag = "Spiders"
	midround_type = HEAVY_MIDROUND
	false_alarm_able = TRUE
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	min_antag_cap = 0
	/// Determines how many eggs to create - can take a formula like antag_cap
	var/egg_count = 2

/datum/dynamic_ruleset/midround/spiders/can_be_selected()
	return ..() && (GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT) && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))

/datum/dynamic_ruleset/midround/spiders/execute()
	var/num_egg = get_antag_cap(length(GLOB.alive_player_list), egg_count)
	while(num_egg > 0)
		var/turf/spawn_loc = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)
		if(isnull(spawn_loc))
			break
		var/obj/effect/mob_spawn/ghost_role/spider/midwife/new_eggs = new(spawn_loc)
		new_eggs.amount_grown = 98
		num_egg--

	addtimer(CALLBACK(src, PROC_REF(announce_spiders)), rand(375, 600) SECONDS)

/datum/dynamic_ruleset/midround/spiders/proc/announce_spiders()
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/dynamic_ruleset/midround/spiders/false_alarm()
	announce_spiders()

/datum/dynamic_ruleset/midround/pirates
	name = "Pirates"
	config_tag = "Light Pirates"
	midround_type = LIGHT_MIDROUND
	jobban_flag = ROLE_TRAITOR
	ruleset_flags = RULESET_INVADER|RULESET_ADMIN_CONFIGURABLE
	weight = 3
	min_pop = 15
	min_antag_cap = 0 // ship will spawn if there are no ghosts around

	/// Pool to pick pirates from
	var/list/datum/pirate_gang/pirate_pool

/datum/dynamic_ruleset/midround/pirates/New(list/dynamic_config)
	. = ..()
	pirate_pool = default_pirate_pool()

/datum/dynamic_ruleset/midround/pirates/can_be_selected()
	return ..() && !SSmapping.is_planetary() && (GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT) && length(default_pirate_pool()) > 0

// An abornmal ruleset that selects no players, but just spawns a pirate ship
/datum/dynamic_ruleset/midround/pirates/execute()
	send_pirate_threat(pirate_pool)

/// Returns what pool of pirates to drawn from
/// Returned list is mutated by the ruleset
/datum/dynamic_ruleset/midround/pirates/proc/default_pirate_pool()
	return GLOB.light_pirate_gangs

/datum/dynamic_ruleset/midround/pirates/heavy
	name = "Pirates"
	config_tag = "Heavy Pirates"
	midround_type = HEAVY_MIDROUND
	jobban_flag = ROLE_TRAITOR
	ruleset_flags = RULESET_INVADER
	weight = 3
	min_pop = 25
	min_antag_cap = 0 // ship will spawn if there are no ghosts around

/datum/dynamic_ruleset/midround/pirates/heavy/default_pirate_pool()
	return GLOB.heavy_pirate_gangs

#define RANDOM_PIRATE_POOL "Random"

/datum/dynamic_ruleset/midround/pirates/configure_ruleset(mob/admin)
	var/list/admin_pool = list("[RULESET_CONFIG_CANCEL]" = TRUE, "[RANDOM_PIRATE_POOL]" = TRUE)
	for(var/datum/pirate_gang/gang as anything in default_pirate_pool())
		admin_pool[gang.name] = gang
	var/picked = tgui_input_list(admin, "Select a pirate gang", "Pirate Gang Selection", admin_pool)
	if(!picked || picked == RULESET_CONFIG_CANCEL)
		return RULESET_CONFIG_CANCEL
	if(picked == RANDOM_PIRATE_POOL)
		return null

	pirate_pool = list(admin_pool[picked])
	return null

#undef RANDOM_PIRATE_POOL

#define NO_ANSWER 0
#define POSITIVE_ANSWER 1
#define NEGATIVE_ANSWER 2

/datum/dynamic_ruleset/midround/pirates/proc/send_pirate_threat(list/pirate_selection)
	var/datum/pirate_gang/chosen_gang = pick_n_take(pirate_selection)
	///If there was nothing to pull from our requested list, stop here.
	if(!chosen_gang)
		message_admins("Error attempting to run the space pirate event, as the given pirate gangs list was empty.")
		return
	//set payoff
	var/payoff = 0
	var/datum/bank_account/account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(account)
		payoff = max(PAYOFF_MIN, FLOOR(account.account_balance * 0.80, 1000))
	var/datum/comm_message/threat = chosen_gang.generate_message(payoff)
	//send message
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())
	threat.answer_callback = CALLBACK(src, PROC_REF(pirates_answered), threat, chosen_gang, payoff, world.time)
	addtimer(CALLBACK(src, PROC_REF(spawn_pirates), threat, chosen_gang), RESPONSE_MAX_TIME)
	GLOB.communications_controller.send_message(threat, unique = TRUE)

/datum/dynamic_ruleset/midround/pirates/proc/pirates_answered(datum/comm_message/threat, datum/pirate_gang/chosen_gang, payoff, initial_send_time)
	if(world.time > initial_send_time + RESPONSE_MAX_TIME)
		priority_announce(chosen_gang.response_too_late, sender_override = chosen_gang.ship_name, color_override = chosen_gang.announcement_color)
		return
	if(!threat?.answered)
		return
	if(threat.answered == NEGATIVE_ANSWER)
		priority_announce(chosen_gang.response_rejected, sender_override = chosen_gang.ship_name, color_override = chosen_gang.announcement_color)
		return

	var/datum/bank_account/plundered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(plundered_account)
		if(plundered_account.adjust_money(-payoff))
			chosen_gang.paid_off = TRUE
			priority_announce(chosen_gang.response_received, sender_override = chosen_gang.ship_name, color_override = chosen_gang.announcement_color)
		else
			priority_announce(chosen_gang.response_not_enough, sender_override = chosen_gang.ship_name, color_override = chosen_gang.announcement_color)

/datum/dynamic_ruleset/midround/pirates/proc/spawn_pirates(datum/comm_message/threat, datum/pirate_gang/chosen_gang)
	if(chosen_gang.paid_off)
		return

	var/list/candidates = SSpolling.poll_ghost_candidates("Do you wish to be considered for a [span_notice("pirate crew of [chosen_gang.name]?")]", check_jobban = ROLE_TRAITOR, alert_pic = /obj/item/claymore/cutlass, role_name_text = "pirate crew")
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

	for(var/turf/area_turf as anything in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/ghost_role/human/pirate/spawner in area_turf)
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				var/mob/spawned_mob = spawner.create_from_ghost(our_candidate)
				candidates -= our_candidate
				notify_ghosts(
					"The [chosen_gang.ship_name] has an object of interest: [spawned_mob]!",
					source = spawned_mob,
					header = "Pirates!",
				)
			else
				notify_ghosts(
					"The [chosen_gang.ship_name] has an object of interest: [spawner]!",
					source = spawner,
					header = "Pirate Spawn Here!",
				)

	priority_announce(chosen_gang.arrival_announcement, sender_override = chosen_gang.ship_name)

#undef NO_ANSWER
#undef POSITIVE_ANSWER
#undef NEGATIVE_ANSWER
/**
 * ### Ghost rulesets
 *
 * Rulesets which select an observer/ghost player to play as a new character
 *
 * Implementation notes:
 * - prepare_role will handle making the body for the mob for you. Avoid touching it if not necessary.
 * - create_ruleset_body is what makes the new /mob for the candidate. It handles putting the player in the body for you.
 * You can override it entirely for to spawn a different mob type.
 * You can also override it to spawn nothing, if you're doing special handling in assign_role, but you'll have to handle moving the player yourself.
 * - assign_role is what gives the player their antag datum.
 */
/datum/dynamic_ruleset/midround/from_ghosts
	///Path of an item to show up in ghost polls for applicants to sign up.
	var/signup_atom_appearance = /obj/structure/sign/poster/contraband/syndicate_recruitment
	/// Text shown in the candidate poll. Optional, if unset uses pref_flag. (Though required if pref_flag is unset)
	var/candidate_role

/datum/dynamic_ruleset/midround/from_ghosts/can_be_selected()
	SHOULD_CALL_PARENT(TRUE)
	return ..() && (GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT)

/datum/dynamic_ruleset/midround/from_ghosts/get_candidate_mind(mob/dead/candidate)
	// Ghost roles will always get a fresh mind
	return new /datum/mind(candidate.key)

/datum/dynamic_ruleset/midround/from_ghosts/prepare_for_role(datum/mind/candidate)
	var/mob/living/body = create_ruleset_body()
	if(isnull(body))
		return
	candidate.transfer_to(body, force_key_move = TRUE) // yoinks the candidate's client
	if(ishuman(body))
		var/mob/living/carbon/human/human_body = body
		body.client?.prefs.safe_transfer_prefs_to(body)
		human_body.dna.remove_all_mutations()
		human_body.dna.update_dna_identity()

/**
 * Handles making the body for the candidate
 *
 * Handling loc is not necessary here - you can do it in assign_role
 *
 * Returning null will skip body creation entirely, though you will be expected to do it yourself in assign_role
 */
/datum/dynamic_ruleset/midround/from_ghosts/proc/create_ruleset_body()
	return new /mob/living/carbon/human

/datum/dynamic_ruleset/midround/from_ghosts/collect_candidates()
	var/readable_poll_role = candidate_role || pref_flag
	if(isnull(readable_poll_role))
		stack_trace("[config_tag]: No candidate role or pref_flag set, give it a human readable candidate roll at the bare minimum.")
		readable_poll_role = "Some Midround Antagonist Without A Role Set (Yell At Coders)"

	return SSpolling.poll_candidates(
		group = trim_candidates(GLOB.dead_player_list | GLOB.current_observers_list),
		question = "Looking for volunteers to become [span_notice(readable_poll_role)] for [span_danger(name)]",
		// check_jobban = list(ROLE_SYNDICATE, jobban_flag || pref_flag), // Not necessary, handled in trim_candidates()
		// role = pref_flag, // Not necessary, handled in trim_candidates()
		poll_time = 30 SECONDS,
		alert_pic = signup_atom_appearance,
		role_name_text = readable_poll_role,
	)

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	config_tag = "Midround Wizard"
	preview_antag_datum = /datum/antagonist/wizard
	midround_type = HEAVY_MIDROUND
	candidate_role = "Wizard"
	pref_flag = ROLE_WIZARD_MIDROUND
	jobban_flag = ROLE_WIZARD
	ruleset_flags = RULESET_INVADER|RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)
	signup_atom_appearance = /obj/item/clothing/head/wizard

/datum/dynamic_ruleset/midround/from_ghosts/wizard/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/wizard) // moves to lair for us

/datum/dynamic_ruleset/midround/from_ghosts/nukies
	name = "Nuclear Operatives"
	config_tag = "Midround Nukeops"
	preview_antag_datum = /datum/antagonist/nukeop
	midround_type = HEAVY_MIDROUND
	candidate_role = "Operative"
	pref_flag = ROLE_OPERATIVE_MIDROUND
	jobban_flag = ROLE_OPERATIVE
	ruleset_flags = RULESET_INVADER|RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 18, "offset" = 1)
	repeatable = FALSE
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate

/datum/dynamic_ruleset/midround/from_ghosts/nukies/create_execute_args()
	return list(
		new /datum/team/nuclear(),
		get_most_experienced(selected_minds, pref_flag),
	)

/datum/dynamic_ruleset/midround/from_ghosts/nukies/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team, datum/mind/most_experienced)
	if(most_experienced == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader, nuke_team) // moves to nuke base for us
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop, nuke_team) // moves to nuke base for us

/datum/dynamic_ruleset/midround/from_ghosts/nukies/round_result()
	var/datum/antagonist/nukeop/nukie = selected_minds[1].has_antag_datum(/datum/antagonist/nukeop)
	var/datum/team/nuclear/nuke_team = nukie.get_team()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/dynamic_ruleset/midround/from_ghosts/nukies/clown
	name = "Clown Operatives"
	config_tag = "Midround Clownops"
	preview_antag_datum = /datum/antagonist/nukeop/clownop
	candidate_role = "Operative"
	pref_flag = ROLE_CLOWN_OPERATIVE_MIDROUND
	jobban_flag = ROLE_CLOWN_OPERATIVE
	weight = 0
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate/bananium

/datum/dynamic_ruleset/midround/from_ghosts/nukies/clown/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team, datum/mind/most_experienced)
	if(most_experienced == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader/clownop, nuke_team) // moves to nuke base for us
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop/clownop, nuke_team) // moves to nuke base for us

/datum/dynamic_ruleset/midround/from_ghosts/blob
	name = "Blob"
	config_tag = "Blob"
	preview_antag_datum = /datum/antagonist/blob
	midround_type = HEAVY_MIDROUND
	false_alarm_able = TRUE
	pref_flag = ROLE_BLOB
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable_weight_decrease = 3
	signup_atom_appearance = /obj/structure/blob/normal
	/// How many points does the blob spawn with
	var/starting_points = OVERMIND_STARTING_POINTS

/datum/dynamic_ruleset/midround/from_ghosts/blob/create_ruleset_body()
	return new /mob/eye/blob(get_blobspawn(), starting_points)

/datum/dynamic_ruleset/midround/from_ghosts/blob/assign_role(datum/mind/candidate)
	return // everything is handled by blob new()

/datum/dynamic_ruleset/midround/from_ghosts/blob/proc/get_blobspawn()
	if(!length(GLOB.blobstart))
		var/obj/effect/landmark/observer_start/default = locate() in GLOB.landmarks_list
		return get_turf(default)

	return pick(GLOB.blobstart)

/datum/dynamic_ruleset/midround/from_ghosts/blob/false_alarm()
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	name = "Alien Infestation"
	config_tag = "Xenomorph"
	preview_antag_datum = /datum/antagonist/xeno
	midround_type = HEAVY_MIDROUND
	false_alarm_able = TRUE
	pref_flag = ROLE_ALIEN
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
		DYNAMIC_TIER_HIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	min_antag_cap = 1
	repeatable_weight_decrease = 3
	signup_atom_appearance = /mob/living/basic/alien

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/New(list/dynamic_config)
	. = ..()
	max_antag_cap += prob(50) // 50% chance to get a second xeno, free!

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/can_be_selected()
	return ..() && length(find_vents()) > 0

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/execute()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(announce_xenos)), rand(375, 600) SECONDS)

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/proc/announce_xenos()
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/false_alarm()
	announce_xenos()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/create_ruleset_body()
	return new /mob/living/carbon/alien/larva

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/create_execute_args()
	return list(find_vents())

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/assign_role(datum/mind/candidate, list/vent_list)
	// xeno login gives antag datums
	var/obj/vent = length(vent_list) >= 2 ? pick_n_take(vent_list) : vent_list[1]
	candidate.current.move_into_vent(vent)

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/proc/find_vents()
	var/list/vents = list()
	var/list/vent_pumps = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in vent_pumps)
		if(QDELETED(temp_vent))
			continue
		if(!is_station_level(temp_vent.loc.z) || temp_vent.welded)
			continue
		var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
		if(!temp_vent_parent)
			continue
		// Stops Aliens getting stuck in small networks.
		// See: Security, Virology
		if(length(temp_vent_parent.other_atmos_machines) <= 20)
			continue
		vents += temp_vent
	return vents

/datum/dynamic_ruleset/midround/from_ghosts/nightmare
	name = "Nightmare"
	config_tag = "Nightmare"
	preview_antag_datum = /datum/antagonist/nightmare
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_NIGHTMARE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/item/light_eater

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/can_be_selected()
	return ..() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/nightmare)
	candidate.current.set_species(/datum/species/shadow/nightmare)
	candidate.current.forceMove(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))
	playsound(candidate.current, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon
	name = "Space Dragon"
	config_tag = "Space Dragon"
	preview_antag_datum = /datum/antagonist/space_dragon
	midround_type = HEAVY_MIDROUND
	false_alarm_able = TRUE
	pref_flag = ROLE_SPACE_DRAGON
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 3,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
		DYNAMIC_TIER_HIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable_weight_decrease = 3
	signup_atom_appearance = /mob/living/basic/space_dragon

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/can_be_selected()
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/create_ruleset_body()
	return new /mob/living/basic/space_dragon

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/space_dragon)
	candidate.current.forceMove(find_space_spawn())
	playsound(candidate.current, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/execute()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(announce_space_dragon)), rand(5, 10) SECONDS)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/proc/announce_space_dragon()
	priority_announce("A large organic energy flux has been recorded near of [station_name()], please stand-by.", "Lifesign Alert")

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/false_alarm()
	announce_space_dragon()

/datum/dynamic_ruleset/midround/from_ghosts/abductors
	name = "Abductors"
	config_tag = "Abductors"
	preview_antag_datum = /datum/antagonist/abductor
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_ABDUCTOR
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 20
	min_antag_cap = 2
	repeatable_weight_decrease = 3
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS)
	signup_atom_appearance = /obj/item/melee/baton/abductor

/datum/dynamic_ruleset/midround/from_ghosts/abductors/can_be_selected()
	if(!..())
		return FALSE
	var/num_abductors = 0
	for(var/datum/team/abductor_team/team in GLOB.antagonist_teams)
		num_abductors++
	return num_abductors < 4

/datum/dynamic_ruleset/midround/from_ghosts/abductors/create_execute_args()
	return list(new /datum/team/abductor_team())

/datum/dynamic_ruleset/midround/from_ghosts/abductors/assign_role(datum/mind/candidate, datum/team/abductor_team/team)
	if(candidate == selected_minds[1])
		candidate.add_antag_datum(/datum/antagonist/abductor/scientist, team) // sets species and moves to spawn point
	else
		candidate.add_antag_datum(/datum/antagonist/abductor/agent, team) // sets species and moves to spawn point

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja
	name = "Space Ninja"
	config_tag = "Space Ninja"
	preview_antag_datum = /datum/antagonist/ninja
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_NINJA
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable = FALSE
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)
	signup_atom_appearance = /obj/item/energy_katana

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/can_be_selected()
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_ninja = candidate.current
	new_ninja.forceMove(find_space_spawn()) // ninja antag datum needs the mob to be in place first
	randomize_human_normie(new_ninja)
	var/new_name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	new_ninja.name = new_name
	new_ninja.real_name = new_name
	new_ninja.dna.update_dna_identity() // ninja antag datum needs dna to be set first
	candidate.add_antag_datum(/datum/antagonist/ninja)

/datum/dynamic_ruleset/midround/from_ghosts/revenant
	name = "Revenant"
	config_tag = "Revenant"
	preview_antag_datum = /datum/antagonist/revenant
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_REVENANT
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	repeatable = FALSE
	signup_atom_appearance = /mob/living/basic/revenant
	/// There must be this many dead mobs on the station for a revenant to spawn (of all mob types, not just humans)
	/// Remember there's usually 2-3 that spawn in the Morgue roundstart, so adjust this accordingly
	var/required_station_corpses = 10

/datum/dynamic_ruleset/midround/from_ghosts/revenant/can_be_selected()
	if(!..())
		return FALSE
	var/num_station_corpses = 0
	for(var/mob/deceased as anything in GLOB.dead_mob_list)
		var/turf/deceased_turf = get_turf(deceased)
		if(is_station_level(deceased_turf?.z))
			num_station_corpses++

	return num_station_corpses > required_station_corpses

/datum/dynamic_ruleset/midround/from_ghosts/revenant/create_ruleset_body()
	return new /mob/living/basic/revenant(pick(get_revenant_spawns()))

/datum/dynamic_ruleset/midround/from_ghosts/revenant/assign_role(datum/mind/candidate)
	return // revenant new() handles everything

/datum/dynamic_ruleset/midround/from_ghosts/revenant/proc/get_revenant_spawns()
	var/list/spawn_locs = list()
	for(var/mob/deceased in GLOB.dead_mob_list)
		var/turf/deceased_turf = get_turf(deceased)
		if(is_station_level(deceased_turf?.z))
			spawn_locs += deceased_turf
	if(!length(spawn_locs) || length(spawn_locs) < 12) // get a comfortably large pool of spawnpoints
		for(var/obj/structure/bodycontainer/corpse_container in GLOB.bodycontainers)
			var/turf/container_turf = get_turf(corpse_container)
			if(is_station_level(container_turf?.z))
				spawn_locs += container_turf
	if(!length(spawn_locs) || length(spawn_locs) < 4) // get a comfortably large pool of spawnpoints
		for(var/obj/effect/landmark/carpspawn/carpspawn in GLOB.landmarks_list)
			spawn_locs += carpspawn.loc

	return spawn_locs

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling
	name = "Space Changeling"
	config_tag = "Midround Changeling"
	preview_antag_datum = /datum/antagonist/changeling/space
	midround_type = LIGHT_MIDROUND
	candidate_role = "Changeling"
	pref_flag = ROLE_CHANGELING_MIDROUND
	jobban_flag = ROLE_CHANGELING
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/meteor/meaty/changeling

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling/create_ruleset_body()
	return // handled by generate_changeling_meteor() entirely

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling/assign_role(datum/mind/candidate)
	generate_changeling_meteor(candidate)

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone
	name = "Paradox Clone"
	config_tag = "Paradox Clone"
	preview_antag_datum = /datum/antagonist/paradox_clone
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_PARADOX_CLONE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/bluespace_stream

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/can_be_selected()
	return ..() && !isnull(find_clone()) && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/create_ruleset_body()
	return // handled by assign_role() entirely

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/good_version = find_clone()
	var/mob/living/carbon/human/bad_version = good_version.make_full_human_copy(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))
	candidate.transfer_to(bad_version, force_key_move = TRUE)

	var/datum/antagonist/paradox_clone/antag = candidate.add_antag_datum(/datum/antagonist/paradox_clone)
	antag.original_ref = WEAKREF(good_version.mind)
	antag.setup_clone()

	playsound(bad_version, 'sound/items/weapons/zapbang.ogg', 30, TRUE)
	bad_version.put_in_hands(new /obj/item/storage/toolbox/mechanical()) //so they dont get stuck in maints

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/proc/find_clone()
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat != CONSCIOUS)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		possible_targets += player

	if(length(possible_targets))
		return pick(possible_targets)
	return null

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker
	name = "Voidwalker"
	config_tag = "Voidwalker"
	preview_antag_datum = /datum/antagonist/voidwalker
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_VOIDWALKER
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 30 // Ensures there's a lot of people near windows
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID)
	signup_atom_appearance = /obj/item/clothing/head/helmet/skull/cosmic

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/can_be_selected()
	return ..() && !SSmapping.is_planetary() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/voidwalker)
	candidate.current.set_species(/datum/species/voidwalker)
	candidate.current.forceMove(find_space_spawn())
	playsound(candidate.current, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives
	name = "Fugitive"
	config_tag = "Fugitives"
	preview_antag_datum = /datum/antagonist/fugitive
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_FUGITIVE
	ruleset_flags = RULESET_INVADER|RULESET_ADMIN_CONFIGURABLE
	weight = 3
	min_pop = 20
	max_antag_cap = 4
	min_antag_cap = 3
	repeatable = FALSE
	signup_atom_appearance = /obj/item/card/id/advanced/prisoner
	/// What backstory is the fugitive(s)?
	VAR_FINAL/fugitive_backstory
	/// What backstory is the hunter(s)?
	VAR_FINAL/hunter_backstory

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/can_be_selected()
	return ..() && !SSmapping.is_planetary() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

// If less than a certain number of candidates accept the poll, it varies how many antags are spawned
/datum/dynamic_ruleset/midround/from_ghosts/fugitives/collect_candidates()
	. = ..()
	if(length(.) <= 1 || prob(30 - (length(.) * 2)))
		min_antag_cap = 1
		max_antag_cap = 1

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/create_execute_args()
	return list(
		new /datum/team/fugitive(),
		find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE),
	)

#define RANDOM_BACKSTORY "Random"

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/configure_ruleset(mob/admin)
	var/list/fugitive_backstories = list(
		FUGITIVE_BACKSTORY_CULTIST,
		FUGITIVE_BACKSTORY_INVISIBLE,
		FUGITIVE_BACKSTORY_PRISONER,
		FUGITIVE_BACKSTORY_SYNTH,
		FUGITIVE_BACKSTORY_WALDO,
		RANDOM_BACKSTORY,
		RULESET_CONFIG_CANCEL,
	)
	var/list/hunter_backstories = list(
		HUNTER_PACK_BOUNTY,
		HUNTER_PACK_COPS,
		HUNTER_PACK_MI13,
		HUNTER_PACK_PSYKER,
		HUNTER_PACK_RUSSIAN,
		RANDOM_BACKSTORY,
		RULESET_CONFIG_CANCEL,
	)

	var/picked_fugitive_backstory = tgui_input_list(admin, "Select a fugitive backstory", "Fugitive Backstory", fugitive_backstories)
	if(!picked_fugitive_backstory || picked_fugitive_backstory == RULESET_CONFIG_CANCEL)
		return RULESET_CONFIG_CANCEL
	if(picked_fugitive_backstory != RANDOM_BACKSTORY)
		fugitive_backstory = picked_fugitive_backstory

	var/picked_hunter_backstory = tgui_input_list(admin, "Select a hunter backstory", "Hunter Backstory", hunter_backstories)
	if(!picked_hunter_backstory || picked_hunter_backstory == RULESET_CONFIG_CANCEL)
		return RULESET_CONFIG_CANCEL
	if(picked_hunter_backstory != RANDOM_BACKSTORY)
		hunter_backstory = picked_hunter_backstory

	return null

#undef RANDOM_BACKSTORY

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/execute()
	if(length(selected_minds) == 1)
		fugitive_backstory ||= pick(
			FUGITIVE_BACKSTORY_INVISIBLE,
			FUGITIVE_BACKSTORY_WALDO,
		)
	else
		fugitive_backstory ||= pick(
			FUGITIVE_BACKSTORY_CULTIST,
			FUGITIVE_BACKSTORY_PRISONER,
			FUGITIVE_BACKSTORY_SYNTH,
		)

	hunter_backstory ||= pick(
		HUNTER_PACK_COPS,
		HUNTER_PACK_RUSSIAN,
		HUNTER_PACK_BOUNTY,
		HUNTER_PACK_PSYKER,
		HUNTER_PACK_MI13,
	)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_spawn_hunters), hunter_backstory, 10 MINUTES), 1 MINUTES)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/assign_role(datum/mind/candidate, datum/team/fugitive/team, turf/team_spawn)
	candidate.current.forceMove(team_spawn)
	equip_fugitive(candidate.current, team)
	if(length(selected_minds) > 1 && candidate == selected_minds[1])
		equip_fugitive_leader(candidate.current)
	playsound(candidate.current, 'sound/items/weapons/emitter.ogg', 50, TRUE)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/proc/equip_fugitive(mob/living/carbon/human/fugitive, datum/team/fugitive/team)
	fugitive.set_species(/datum/species/human)
	randomize_human_normie(fugitive)

	var/datum/antagonist/fugitive/antag = new()
	antag.backstory = fugitive_backstory
	fugitive.mind.add_antag_datum(antag, team)
	// Should really datumize this at some point
	switch(fugitive_backstory)
		if(FUGITIVE_BACKSTORY_PRISONER)
			fugitive.equipOutfit(/datum/outfit/prisoner)
		if(FUGITIVE_BACKSTORY_CULTIST)
			fugitive.equipOutfit(/datum/outfit/yalp_cultist)
		if(FUGITIVE_BACKSTORY_WALDO)
			fugitive.equipOutfit(/datum/outfit/waldo)
		if(FUGITIVE_BACKSTORY_SYNTH)
			fugitive.equipOutfit(/datum/outfit/synthetic)
		if(FUGITIVE_BACKSTORY_INVISIBLE)
			fugitive.equipOutfit(/datum/outfit/invisible_man)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/proc/equip_fugitive_leader(mob/living/carbon/human/fugitive)
	var/turf/leader_turf = get_turf(fugitive)
	var/obj/item/storage/toolbox/mechanical/toolbox = new(leader_turf)
	fugitive.put_in_hands(toolbox)

	switch(fugitive_backstory)
		if(FUGITIVE_BACKSTORY_SYNTH)
			new /obj/item/choice_beacon/augments(leader_turf)
			new /obj/item/autosurgeon(leader_turf)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/proc/check_spawn_hunters(remaining_time)
	//if the emergency shuttle has been called, spawn hunters now to give them a chance
	if(remaining_time == 0 || !EMERGENCY_IDLE_OR_RECALLED)
		spawn_hunters()
		return
	addtimer(CALLBACK(src, PROC_REF(check_spawn_hunters), remaining_time - 1 MINUTES), 1 MINUTES)

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/proc/spawn_hunters()
	var/list/candidates = SSpolling.poll_ghost_candidates("Do you wish to be considered for a group of [span_notice(hunter_backstory)]?", check_jobban = list(ROLE_FUGITIVE_HUNTER, ROLE_SYNDICATE), alert_pic = /obj/machinery/sleeper, role_name_text = hunter_backstory)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/hunter/ship
	switch(hunter_backstory)
		if(HUNTER_PACK_COPS)
			ship = new /datum/map_template/shuttle/hunter/space_cop
		if(HUNTER_PACK_RUSSIAN)
			ship = new /datum/map_template/shuttle/hunter/russian
		if(HUNTER_PACK_BOUNTY)
			ship = new /datum/map_template/shuttle/hunter/bounty
		if(HUNTER_PACK_PSYKER)
			ship = new /datum/map_template/shuttle/hunter/psyker
		if(HUNTER_PACK_MI13)
			ship = new/datum/map_template/shuttle/hunter/mi13_foodtruck

	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/placement_turf = locate(x, y ,z)
	if(!placement_turf)
		CRASH("Fugitive Hunters (Created from fugitive event) found no turf to load in")
	if(!ship.load(placement_turf))
		CRASH("Loading [hunter_backstory] ship failed!")

	for(var/turf/shuttle_turf in ship.get_affected_turfs(placement_turf))
		for(var/obj/effect/mob_spawn/ghost_role/human/fugitive/spawner in shuttle_turf)
			if(length(candidates))
				var/mob/our_candidate = candidates[1]
				var/mob/spawned_mob = spawner.create_from_ghost(our_candidate)
				candidates -= our_candidate
				notify_ghosts(
					"[spawner.prompt_name] has awoken: [spawned_mob]!",
					source = spawned_mob,
					header = "Come look!",
				)
			else
				notify_ghosts(
					"[spawner.prompt_name] spawner has been created!",
					source = spawner,
					header = "Spawn Here!",
				)

	var/list/announcement_text_list = list()
	var/announcement_title = ""
	switch(hunter_backstory)
		if(HUNTER_PACK_COPS)
			announcement_text_list += "Attention Crew of [station_name()], this is the Police. A wanted criminal has been reported taking refuge on your station."
			announcement_text_list += "We have a warrant from the SSC authorities to take them into custody. Officers have been dispatched to your location."
			announcement_text_list += "We demand your cooperation in bringing this criminal to justice."
			announcement_title += "Spacepol Command"
		if(HUNTER_PACK_RUSSIAN)
			announcement_text_list += "Zdraviya zhelaju, [station_name()] crew. We are coming to your station."
			announcement_text_list += "There is a criminal aboard. We will arrest them and return them to the gulag. That's good, yes?"
			announcement_title += "Russian Freighter"
		if(HUNTER_PACK_BOUNTY)
			announcement_text_list += "[station_name()]. One of our bounty marks has ended up on your station. We will be arriving to collect shortly."
			announcement_text_list += "Let's make this quick. If you don't want trouble, stay the hell out of our way."
			announcement_title += "Unregistered Signal"
		if(HUNTER_PACK_PSYKER)
			announcement_text_list += "HEY, CAN YOU HEAR US? We're coming to your station. There's a bad guy down there, really bad guy. We need to arrest them."
			announcement_text_list += "We're also offering fortune telling services out of the front door if you have paying customers."
			announcement_title += "Fortune-Telling Entertainment Shuttle"
		if(HUNTER_PACK_MI13)
			announcement_text_list += "Illegal intrusion detected in the crew monitoring network. Central Command has been informed."
			announcement_text_list += "Please report any suspicious individuals or behaviour to your local security team."
			announcement_title += "Nanotrasen Intrusion Countermeasures Electronics"

	if(!length(announcement_text_list))
		announcement_text_list += "Unidentified ship detected near the station."
		stack_trace("Fugitive hunter announcement was unable to generate an announcement text based on backstory: [hunter_backstory]")

	if(!length(announcement_title))
		announcement_title += "Unknown Signal"
		stack_trace("Fugitive hunter announcement was unable to generate an announcement title based on backstory: [hunter_backstory]")

	priority_announce(jointext(announcement_text_list, " "), announcement_title)

/datum/dynamic_ruleset/midround/from_ghosts/morph
	name = "Morph"
	config_tag = "Morph"
	// preview_antag_datum = /datum/antagonist/morph // Doesn't actually have its own pref
	midround_type = LIGHT_MIDROUND
	candidate_role = "Morphling"
	jobban_flag = ROLE_ALIEN
	ruleset_flags = RULESET_INVADER
	weight = 0
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/morph

/datum/dynamic_ruleset/midround/from_ghosts/morph/can_be_selected()
	return ..() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

/datum/dynamic_ruleset/midround/from_ghosts/morph/create_ruleset_body()
	return new /mob/living/basic/morph(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

/datum/dynamic_ruleset/midround/from_ghosts/morph/assign_role(datum/mind/candidate)
	candidate.set_assigned_role(SSjob.get_job_type(/datum/job/morph))
	candidate.add_antag_datum(/datum/antagonist/morph)

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon
	name = "Slaughter Demon"
	config_tag = "Slaughter Demon"
	candidate_role = "Slaughter Demon"
	// preview_antag_datum = /datum/antagonist/slaughter // Doesn't actually have its own pref
	midround_type = HEAVY_MIDROUND
	jobban_flag = ROLE_ALIEN
	ruleset_flags = RULESET_INVADER
	weight = 0
	min_pop = 20
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/demon/slaughter

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon/can_be_selected()
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon/create_ruleset_body()
	var/turf/spawnloc = find_space_spawn()
	. = new /mob/living/basic/demon/slaughter(spawnloc)
	new /obj/effect/dummy/phased_mob/blood(spawnloc, .)

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon/assign_role(datum/mind/candidate)
	return // handled by new() entirely

/datum/dynamic_ruleset/midround/from_living
	min_antag_cap = 1
	max_antag_cap = 1
	repeatable = TRUE

/datum/dynamic_ruleset/midround/from_living/set_config_value(nvar, nval)
	if(nvar == NAMEOF(src, min_antag_cap) || nvar == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_living/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, min_antag_cap) || var_name == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_living/collect_candidates()
	return GLOB.alive_player_list

/datum/dynamic_ruleset/midround/from_living/is_valid_candidate(mob/candidate, client/candidate_client)
	if(candidate.stat == DEAD || isnull(candidate.mind))
		return FALSE
	// only pick members of the crew
	if(!job_check(candidate))
		return FALSE
	if(!antag_check(candidate))
		return FALSE
	// checks for stuff like bitrunner avatars and ghost mafia
	if(HAS_TRAIT(candidate, TRAIT_MIND_TEMPORARILY_GONE) || HAS_TRAIT(candidate, TRAIT_TEMPORARY_BODY))
		return FALSE
	if(SEND_SIGNAL(candidate, COMSIG_MOB_MIND_BEFORE_MIDROUND_ROLL, src, pref_flag) & CANCEL_ROLL)
		return FALSE
	return ..()

/// Checks if the candidate is a valid job for this ruleset - by default you probably only want crew members. (Return FALSE to mark the candidate invalid)
/datum/dynamic_ruleset/midround/from_living/proc/job_check(mob/candidate)
	if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
		return FALSE
	if(candidate.mind.assigned_role.title in get_blacklisted_roles())
		return FALSE
	return TRUE

/// Checks if the candidate is an antag - most of the time you don't want to double dip. (Return FALSE to mark the candidate invalid)
/datum/dynamic_ruleset/midround/from_living/proc/antag_check(mob/candidate)
	return !candidate.is_antag()

/datum/dynamic_ruleset/midround/from_living/traitor
	name = "Traitor"
	config_tag = "Midround Traitor"
	preview_antag_datum = /datum/antagonist/traitor
	midround_type = LIGHT_MIDROUND
	false_alarm_able = TRUE
	pref_flag = ROLE_SLEEPER_AGENT
	jobban_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/midround/from_living/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/midround/from_living/traitor/false_alarm()
	priority_announce(
		"Attention crew, it appears that someone on your station has hijacked your telecommunications and broadcasted an unknown signal.",
		"[command_name()] High-Priority Update",
	)

/datum/dynamic_ruleset/midround/from_living/malf_ai
	name = "Malfunctioning AI"
	config_tag = "Midround Malfunctioning AI"
	preview_antag_datum = /datum/antagonist/malf_ai
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_MALF_MIDROUND
	jobban_flag = ROLE_MALF
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	repeatable = FALSE

/datum/dynamic_ruleset/midround/from_living/malf_ai/get_always_blacklisted_roles()
	return list()

/datum/dynamic_ruleset/midround/from_living/malf_ai/job_check(mob/candidate)
	return istype(candidate.mind.assigned_role, /datum/job/ai)

/datum/dynamic_ruleset/midround/from_living/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/midround/from_living/malf_ai/can_be_selected()
	return ..() && !HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI)

/datum/dynamic_ruleset/midround/from_living/blob
	name = "Blob Infection"
	config_tag = "Blob Infection"
	preview_antag_datum = /datum/antagonist/blob/infection
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_BLOB_INFECTION
	jobban_flag = ROLE_BLOB
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	repeatable_weight_decrease = 3

/datum/dynamic_ruleset/midround/from_living/blob/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/blob/infection)
	notify_ghosts(
		"[candidate.current.real_name] has become a blob host!",
		source = candidate.current,
		header = "So Bulbous...",
	)

/datum/dynamic_ruleset/midround/from_living/obsesed
	name = "Obsession"
	config_tag = "Midround Obsessed"
	preview_antag_datum = /datum/antagonist/obsessed
	midround_type = LIGHT_MIDROUND
	pref_flag = ROLE_OBSESSED
	blacklisted_roles = list()
	weight = list(
		DYNAMIC_TIER_LOW = 5,
		DYNAMIC_TIER_LOWMEDIUM = 5,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 1,
	)
	min_pop = 5

/datum/dynamic_ruleset/midround/from_living/obsesed/is_valid_candidate(mob/candidate, client/candidate_client)
	return ..() && !!candidate.get_organ_by_type(/obj/item/organ/brain)

/datum/dynamic_ruleset/midround/from_living/obsesed/antag_check(mob/candidate)
	// Obsessed is a special case, it can select other antag players
	return !candidate.mind.has_antag_datum(/datum/antagonist/obsessed)

/datum/dynamic_ruleset/midround/from_living/obsesed/assign_role(datum/mind/candidate)
	var/obj/item/organ/brain/brain = candidate.current.get_organ_by_type(__IMPLIED_TYPE__)
	brain.brain_gain_trauma(/datum/brain_trauma/special/obsessed)
	notify_ghosts(
		"[candidate.current.real_name] has developed an obsession with someone!",
		source = candidate.current,
		header = "Love Can Bloom",
	)
