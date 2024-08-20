/datum/round_event_control/antagonist/solo/from_ghosts/paradox_clone
	name = "Paradox Clone"
	tags = list(TAG_OUTSIDER_ANTAG, TAG_SPOOKY, TAG_TARGETED)
	typepath = /datum/round_event/antagonist/solo/ghost/paradox_clone
	antag_flag = ROLE_PARADOX_CLONE
	track = EVENT_TRACK_MAJOR
	antag_datum = /datum/antagonist/paradox_clone
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
	)
	maximum_antags = 1
	required_enemies = 2
	weight = 6
	max_occurrences = 2
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/ghost/paradox_clone
	var/list/possible_spawns = list() ///places the antag can spawn
	var/mob/living/carbon/human/clone_victim
	var/mob/living/carbon/human/new_human

/datum/round_event/antagonist/solo/ghost/paradox_clone/setup()
	possible_spawns += find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE)
	if(!possible_spawns.len)
		return
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client
	if(length(cliented_list))
		mass_adjust_antag_rep(cliented_list, 1)


	if(prompted_picking)
		candidates = SSpolling.poll_ghost_candidates(
			"Would you like to be a paradox clone?",
			check_jobban = ROLE_PARADOX_CLONE,
			poll_time = 20 SECONDS,
			alert_pic = /datum/antagonist/paradox_clone,
			role_name_text = "paradox clone",
			chat_text_border_icon = /datum/antagonist/paradox_clone,
		)

	var/list/weighted_candidates = return_antag_rep_weight(candidates)

	for(var/i in 1 to antag_count)
		if(!length(candidates))
			break

		var/client/mob_client = pick_n_take(weighted_candidates)
		var/mob/candidate = mob_client.mob

		if(candidate.client) //I hate this
			candidate.client.prefs.reset_antag_rep()

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		clone_victim = find_original()
		new_human = duplicate_object(clone_victim, pick(possible_spawns))
		new_human.key = candidate.key
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind
	setup = TRUE


/datum/round_event/antagonist/solo/ghost/paradox_clone/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/paradox_clone/new_datum = antag_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	new_datum.original_ref = WEAKREF(clone_victim.mind)
	new_datum.setup_clone()
	playsound(new_human, 'sound/weapons/zapbang.ogg', 30, TRUE)
	new /obj/item/storage/toolbox/mechanical(new_human.loc) //so they dont get stuck in maints

	message_admins("[ADMIN_LOOKUPFLW(new_human)] has been made into a Paradox Clone by the midround ruleset.")
	new_human.log_message("was spawned as a Paradox Clone of [key_name(new_human)] by the midround ruleset.", LOG_GAME)


/**
 * Trims through GLOB.player_list and finds a target
 * Returns a single human victim, if none is possible then returns null.
 */
/datum/round_event/antagonist/solo/ghost/paradox_clone/proc/find_original()
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		possible_targets += player

	if(possible_targets.len)
		return pick(possible_targets)
	return FALSE
