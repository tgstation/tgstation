GLOBAL_DATUM(revolution_handler, /datum/revolution_handler)

/datum/revolution_handler
	/// The revolution team
	var/datum/team/revolution/revs

	/// The objective of the heads of staff, aka to kill the headrevs.
	var/list/datum/objective/mutiny/heads_objective = list()

	/// Cooldown between head revs being promoted
	COOLDOWN_DECLARE(rev_head_promote_cd)

	var/result

/datum/revolution_handler/New()
	revs = new()

/datum/revolution_handler/proc/start_revolution()
	if((datum_flags & DF_ISPROCESSING) || result)
		return
	START_PROCESSING(SSprocessing, src)
	SSshuttle.registerHostileEnvironment(src)

	for(var/datum/mind/mutiny_target as anything in SSjob.get_all_heads())
		var/datum/objective/mutiny/new_target = new()
		new_target.team = revs
		new_target.target = mutiny_target
		new_target.update_explanation_text()
		revs.objectives += new_target

	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, PROC_REF(update_objectives))
	COOLDOWN_START(src, rev_head_promote_cd, 5 MINUTES)

/datum/revolution_handler/proc/cleanup()
	STOP_PROCESSING(SSprocessing, src)
	SSshuttle.clearHostileEnvironment(src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN)

/datum/revolution_handler/process(seconds_per_tick)
	if(check_rev_victory())
		declare_revs_win()
		. = PROCESS_KILL

	else if(check_heads_victory())
		declare_heads_win()
		. = PROCESS_KILL

	if(. == PROCESS_KILL)
		cleanup()
		return .

	if(COOLDOWN_FINISHED(src, rev_head_promote_cd))
		revs.update_rev_heads()
		COOLDOWN_START(src, rev_head_promote_cd, 5 MINUTES)

	return .

/datum/revolution_handler/proc/update_objectives(datum/source, datum/job/job, mob/living/spawned)
	SIGNAL_HANDLER

	if(!(job.job_flags & JOB_HEAD_OF_STAFF))
		return

	var/datum/objective/mutiny/new_target = new()
	new_target.team = revs
	new_target.target = spawned.mind
	new_target.update_explanation_text()
	revs.objectives += new_target

/datum/revolution_handler/proc/declare_revs_win()
	for(var/datum/mind/headrev_mind as anything in revs.ex_headrevs)
		var/mob/living/real_headrev = headrev_mind.current
		if(isnull(real_headrev))
			continue
		add_memory_in_range(real_headrev, 5, /datum/memory/revolution_rev_victory, protagonist = real_headrev)

	result = REVOLUTION_VICTORY

/datum/revolution_handler/proc/declare_heads_win()
	// Save rev lists before we remove the antag datums.
	revs.save_members()

	// Remove everyone as a revolutionary
	for(var/datum/mind/rev_mind as anything in revs.members)
		var/datum/antagonist/rev/rev_antag = rev_mind.has_antag_datum(/datum/antagonist/rev)
		if (!isnull(rev_antag))
			rev_antag.remove_revolutionary(DECONVERTER_STATION_WIN)
			if(rev_mind in revs.ex_headrevs)
				LAZYADD(rev_mind.special_roles, "Former Head Revolutionary")
			else
				LAZYADD(rev_mind.special_roles, "Former Revolutionary")

	// If the revolution was quelled, make rev heads unable to be revived through pods
	for(var/datum/mind/rev_head as anything in revs.ex_headrevs)
		if(!isnull(rev_head.current))
			ADD_TRAIT(rev_head.current, TRAIT_DEFIB_BLACKLISTED, REF(src))

	for(var/datum/objective/mutiny/head_tracker in revs.objectives)
		var/mob/living/head_of_staff = head_tracker.target?.current
		if(!isnull(head_of_staff))
			add_memory_in_range(head_of_staff, 5, /datum/memory/revolution_heads_victory, protagonist = head_of_staff)

	priority_announce("It appears the mutiny has been quelled. Please return yourself and your incapacitated colleagues to work. \
		We have remotely blacklisted the head revolutionaries in your medical records to prevent accidental revival.", null, null, null, "[command_name()] Loyalty Monitoring Division")

	result = STATION_VICTORY

/datum/revolution_handler/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revs.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/datum/revolution_handler/proc/check_heads_victory()
	// List of headrevs we're currently tracking
	var/list/included_headrevs = list()
	// List of current headrevs
	var/list/current_headrevs = revs.get_head_revolutionaries()
	// A copy of the head of staff objective list, since we're going to be modifying the original list.
	var/list/heads_objective_copy = heads_objective.Copy()

	var/objective_complete = TRUE
	// Here, we check current head of staff objectives and remove them if the target doesn't exist as a headrev anymore
	for(var/datum/objective/mutiny/objective in heads_objective_copy)
		if(!(objective.target in current_headrevs))
			heads_objective -= objective
			continue
		if(!objective.check_completion())
			objective_complete = FALSE
		included_headrevs += objective.target

	// Here, we check current headrevs and add them as objectives if they didn't exist as a head of staff objective before.
	// Additionally, we make sure the objective is not completed by running the check_completion check on them.
	for(var/datum/mind/rev_mind as anything in current_headrevs)
		if(!(rev_mind in included_headrevs))
			var/datum/objective/mutiny/objective = new()
			objective.target = rev_mind
			if(!objective.check_completion())
				objective_complete = FALSE
			heads_objective += objective

	return objective_complete

/// Checks if someone is valid to be a headrev
/proc/can_be_headrev(datum/mind/candidate)
	var/turf/head_turf = get_turf(candidate.current)
	if(considered_afk(candidate))
		return FALSE
	if(!considered_alive(candidate))
		return FALSE
	if(!is_station_level(head_turf.z))
		return FALSE
	if(candidate.current.is_antag())
		return FALSE
	if(candidate.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
		return FALSE
	if(HAS_MIND_TRAIT(candidate.current, TRAIT_UNCONVERTABLE))
		return FALSE
	return TRUE
