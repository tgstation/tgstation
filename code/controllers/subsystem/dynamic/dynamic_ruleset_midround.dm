/datum/dynamic_ruleset/midround
	/// MIDROUND_RULESET_STYLE_LIGHT or MIDROUND_RULESET_STYLE_HEAVY - determines which pool it enters
	var/midround_type
	/// Text shown in the candidate poll. Optional, if unset uses pref_flag. (Though required if pref_flag is unset)
	var/candidate_role

/**
 * Collect candidates handles getting the broad pool of players we want to pick from
 * This differs from trim candidates which filters the pool of players down to just people who want the antag (and are eligible)
 * You can sleep in this, say, if you wanted to poll players.
 */
/datum/dynamic_ruleset/midround/proc/collect_candidates()
	return list()

/datum/dynamic_ruleset/midround/from_ghosts
	///Path of an item to show up in ghost polls for applicants to sign up.
	var/signup_atom_appearance = /obj/structure/sign/poster/contraband/syndicate_recruitment

/datum/dynamic_ruleset/midround/from_ghosts/can_be_selected(population_size, list/antag_candidates)
	SHOULD_CALL_PARENT(TRUE)
	return ..() && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT)

/datum/dynamic_ruleset/from_ghosts/get_candidate_mind(mob/dead/candidate)
	// Ghost roles will always get a fresh mind
	return new /datum/mind(candidate.key)

/datum/dynamic_ruleset/midround/from_ghosts/collect_candidates()
	var/poll_role = candidate_role || pref_flag
	if(isnull(poll_role))
		stack_trace("[config_tag]: No candidate role or pref_flag set, give it a human readable candidate roll at the bare minimum.")
		poll_role = "Some Midround Antagonist Without A Role Set (Yell At Coders)"

	return SSpolling.poll_ghost_candidates(
		question = "Looking for volunteers to become [span_notice(poll_role)] for [span_danger(name)]",
		check_jobban = list(ROLE_SYNDICATE, jobban_flag || pref_flag),
		role = pref_flag,
		poll_time = 30 SECONDS,
		alert_pic = signup_atom_appearance,
		role_name_text = poll_role,
	)

/// Helper to make a human from a ghost, with their preferences
/datum/dynamic_ruleset/midround/from_ghosts/proc/make_human(mob/dead/ghost, atom/spawn_loc)
	var/mob/living/carbon/human/new_character = make_body(ghost)
	new_character.dna.remove_all_mutations()
	new_character.forceMove(spawn_loc)
	return new_character

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	config_tag = "Midround Wizard"
	preview_antag_datum = /datum/antagonist/wizard
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_WIZARD_MIDROUND
	jobban_flag = ROLE_WIZARD
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)
	signup_atom_appearance = /obj/item/clothing/head/wizard

/datum/dynamic_ruleset/midround/from_ghosts/wizard/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/wizard = make_human(candidate.current, pick(GLOB.wizardstart))
	candidate.transfer_to(wizard, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/wizard)

/datum/dynamic_ruleset/midround/from_ghosts/nukies
	name = "Nuclear Operatives"
	config_tag = "Midround Nukeops"
	preview_antag_datum = /datum/antagonist/nukeop
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_OPERATIVE_MIDROUND
	jobban_flag = ROLE_NUCLEAR_OPERATIVE
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 18, "offset" = 1)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate

/datum/dynamic_ruleset/midround/from_ghosts/nukies/create_execute_args()
	return list(new /datum/team/nuclear)

/datum/dynamic_ruleset/midround/from_ghosts/nukies/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, pick(GLOB.nukeop_start))
	candidate.transfer_to(new_character, force_key_move = TRUE)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop, nuke_team)

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
	pref_flag = ROLE_CLOWN_OPERATIVE_MIDROUND
	jobban_flag = ROLE_CLOWN_OPERATIVE
	weight = 0
	signup_atom_appearance = /obj/machinery/nuclearbomb/syndicate/bananium

/datum/dynamic_ruleset/midround/from_ghosts/nukies/clown/assign_role(datum/mind/candidate, datum/team/nuclear/nuke_team)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, pick(GLOB.nukeop_start))
	candidate.transfer_to(new_character, force_key_move = TRUE)
	if(get_most_experienced(selected_minds, pref_flag) == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader/clownop, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop/clownop, nuke_team)

/datum/dynamic_ruleset/midround/from_ghosts/blob
	name = "Blob"
	config_tag = "Blob"
	preview_antag_datum = /datum/antagonist/blob
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_BLOB
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1
	signup_atom_appearance = /obj/structure/blob/normal

/datum/dynamic_ruleset/midround/from_ghosts/blob/assign_role(datum/mind/candidate)
	candidate.current.become_overmind()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	name = "Alien Infestation"
	config_tag = "Xenomorph"
	preview_antag_datum = /datum/antagonist/xeno
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_ALIEN
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	min_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/alien

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/New(list/dynamic_config)
	. = ..()
	max_antag_cap += prob(50) // 50% chance to get a second xeno, free!

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/can_be_selected(population_size, list/antag_candidates)
	return ..() && length(find_vents()) > 0

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/create_execute_args()
	return list(find_vents())

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/assign_role(datum/mind/candidate, list/vent_list)
	var/obj/vent = length(vent_list) >= 2 ? pick_n_take(vent_list) : vent_list[1]
	var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
	candidate.transfer_to(new_xeno, force_key_move = TRUE)
	new_xeno.move_into_vent(vent)

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
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_NIGHTMARE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/item/light_eater

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE))
	candidate.add_antag_datum(/datum/antagonist/nightmare)
	candidate.transfer_to(new_character)
	new_character.set_species(/datum/species/shadow/nightmare)
	playsound(new_character, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon
	name = "Space Dragon"
	config_tag = "Space Dragon"
	preview_antag_datum = /datum/antagonist/space_dragon
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_SPACE_DRAGON
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 3,
		DYNAMIC_TIER_MEDIUMHIGH = 5,
	)
	min_pop = 30
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/space_dragon

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/assign_role(datum/mind/candidate)
	var/mob/living/basic/space_dragon/dragon = new(find_space_spawn())
	candidate.transfer_to(dragon, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/space_dragon)
	playsound(dragon, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/execute()
	. = ..()
	priority_announce("A large organic energy flux has been recorded near of [station_name()], please stand-by.", "Lifesign Alert")

/datum/dynamic_ruleset/midround/from_ghosts/abductors
	name = "Abductors"
	config_tag = "Abductors"
	preview_antag_datum = /datum/antagonist/abductor
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_ABDUCTOR
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 20
	min_antag_cap = 2
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS)
	signup_atom_appearance = /obj/item/melee/baton/abductor

// melbert todo : where did abductor code go

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja
	name = "Space Ninja"
	config_tag = "Space Ninja"
	preview_antag_datum = /datum/antagonist/ninja
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_NINJA
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)
	signup_atom_appearance = /obj/item/energy_katana

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/space_ninja/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_space_spawn())
	candidate.transfer_to(new_character, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/ninja)

/datum/dynamic_ruleset/midround/from_ghosts/spiders
	name = "Spiders"
	config_tag = "Spiders"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_SPIDER
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	min_pop = 30
	max_antag_cap = 2 // determines how many eggs spawn
	min_antag_cap = 0 // eggs will spawn if there are no ghosts around

// An abornmal ruleset that selects no players, but just spawns eggs
/datum/dynamic_ruleset/midround/from_ghosts/spiders/execute()
	create_midwife_eggs(get_antag_cap(length(GLOB.alive_player_list), max_antag_cap))

/datum/dynamic_ruleset/midround/from_ghosts/revenant
	name = "Revenant"
	config_tag = "Revenant"
	preview_antag_datum = /datum/antagonist/revenant
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_REVENANT
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	signup_atom_appearance = /mob/living/basic/revenant
	/// There must be this many dead mobs on the station for a revenant to spawn (of all mob types, not just humans)
	/// Remember there's usually 2-3 that spawn in the Morgue roundstart, so adjust this accordingly
	var/required_station_corpses = 10

/datum/dynamic_ruleset/midround/from_ghosts/revenant/can_be_selected(population_size, list/antag_candidates)
	if(!..())
		return FALSE
	var/num_station_corpses = 0
	for(var/mob/deceased as anything in GLOB.dead_mob_list)
		var/turf/deceased_turf = get_turf(deceased)
		if(is_station_level(deceased_turf?.z))
			num_station_corpses++

	return num_station_corpses > required_station_corpses

/datum/dynamic_ruleset/midround/from_ghosts/revenant/assign_role(datum/mind/candidate)
	var/mob/living/basic/revenant/revenant = new(pick(get_revenant_spawns()))
	candidate.transfer_to(revenant, force_key_move = TRUE)

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

/datum/dynamic_ruleset/midround/from_ghosts/pirates
	name = "Pirates"
	config_tag = "Light Pirates"
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	jobban_flag = ROLE_TRAITOR
	ruleset_flags = RULESET_INVADER
	weight = 3
	min_pop = 15
	min_antag_cap = 0 // ship will spawn if there are no ghosts around
	signup_atom_appearance = /obj/item/clothing/head/costume/pirate
	candidate_role = "Space Pirates"

/datum/dynamic_ruleset/midround/from_ghosts/pirates/can_be_selected(population_size, list/antag_candidates)
	return ..() && !SSmapping.is_planetary() && length(pirate_pool()) > 0

// An abornmal ruleset that selects no players, but just spawns a pirate ship
/datum/dynamic_ruleset/midround/from_ghosts/pirates/execute()
	send_pirate_threat(pirate_pool())

/datum/dynamic_ruleset/midround/from_ghosts/pirates/proc/pirate_pool()
	return GLOB.light_pirate_gangs

/datum/dynamic_ruleset/midround/from_ghosts/pirates/heavy
	name = "Pirates"
	config_tag = "Heavy Pirates"
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	jobban_flag = ROLE_TRAITOR
	ruleset_flags = RULESET_INVADER
	weight = 3
	min_pop = 25
	min_antag_cap = 0 // ship will spawn if there are no ghosts around

/datum/dynamic_ruleset/midround/from_ghosts/pirates/heavy/pirate_pool()
	return GLOB.heavy_pirate_gangs

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling
	name = "Space Changeling"
	config_tag = "Midround Changeling"
	preview_antag_datum = /datum/antagonist/changeling/space
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_CHANGELING_MIDROUND
	jobban_flag = ROLE_CHANGELING
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/meteor/meaty/changeling

/datum/dynamic_ruleset/midround/from_ghosts/space_changeling/assign_role(datum/mind/candidate)
	generate_changeling_meteor(candidate)

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone
	name = "Paradox Clone"
	config_tag = "Paradox Clone"
	preview_antag_datum = /datum/antagonist/paradox_clone
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_PARADOX_CLONE
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 10
	max_antag_cap = 1
	signup_atom_appearance = /obj/effect/bluespace_stream

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/can_be_selected(population_size, list/antag_candidates)
	return ..() && !isnull(find_clone()) && !isnull(find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE))

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
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_VOIDWALKER
	ruleset_flags = RULESET_INVADER
	weight = 5
	min_pop = 15
	max_antag_cap = 1
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID)
	signup_atom_appearance = /obj/item/clothing/head/helmet/skull/cosmic

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/can_be_selected(population_size, list/antag_candidates)
	return ..() && !SSmapping.is_planetary() && !isnull(find_space_spawn())

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/assign_role(datum/mind/candidate)
	var/mob/living/carbon/human/new_character = make_human(candidate.current, find_space_spawn())
	candidate.transfer_to(new_character, force_key_move = TRUE)
	candidate.add_antag_datum(/datum/antagonist/voidwalker)
	candidate.current.set_species(/datum/species/voidwalker)

	playsound(new_character, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/dynamic_ruleset/midround/from_living
	min_antag_cap = 1
	max_antag_cap = 1

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
	if(candidate.stat == DEAD)
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
	return TRUE

/// Checks if the candidate is a valid job for this ruleset - by default you probably only want crew members
/datum/dynamic_ruleset/midround/from_living/proc/job_check(mob/candidate)
	return !(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)

/// Checks if the candidate is an antag - most of the time you don't want to double dip
/datum/dynamic_ruleset/midround/from_living/proc/antag_check(mob/candidate)
	return !candidate.is_antag()

/datum/dynamic_ruleset/midround/from_living/traitor
	name = "Traitor"
	config_tag = "Midround Traitor"
	preview_antag_datum = /datum/antagonist/traitor
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_SLEEPER_AGENT
	jobban_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/midround/from_living/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/midround/from_living/malf_ai
	name = "Malfunctioning AI"
	config_tag = "Midround Malfunctioning AI"
	preview_antag_datum = /datum/antagonist/malf_ai
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_MALF_MIDROUND
	jobban_flag = ROLE_MALF
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30

/datum/dynamic_ruleset/midround/from_living/malf_ai/get_always_blacklisted_roles()
	return list()

/datum/dynamic_ruleset/midround/from_living/malf_ai/job_check(mob/candidate)
	return istype(candidate.mind.assigned_role, /datum/job/ai)

/datum/dynamic_ruleset/midround/from_living/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/midround/from_living/blob
	name = "Blob Infection"
	config_tag = "Midround Blob"
	preview_antag_datum = /datum/antagonist/blob/infection
	midround_type = MIDROUND_RULESET_STYLE_HEAVY
	pref_flag = ROLE_BLOB_INFECTION
	jobban_flag = ROLE_BLOB
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
	)
	min_pop = 30

/datum/dynamic_ruleset/midround/from_living/blob/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/blob/infection)
	notify_ghosts(
		"[candidate.current.real_name] has become a blob host!",
		source = candidate.current,
		header = "So Bulbous...",
	)

/datum/dynamic_ruleset/midround/from_living/obsesed
	name = "Obsessed"
	config_tag = "Midround Obsessed"
	preview_antag_datum = /datum/antagonist/obsessed
	midround_type = MIDROUND_RULESET_STYLE_LIGHT
	pref_flag = ROLE_OBSESSED
	blacklisted_roles = list()
	weight = list(
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
