/datum/controller/subsystem/job
	/// Assoc list of new players keyed to the type of job they will currently get
	var/list/assigned_players_by_job = list()
	/// Nested assoc list of job types with values of lists of players who are viable for that job, keyed to what priority level that player has the job set to in their prefs
	var/list/assignable_by_job = list()

/// Handle all the stuff for temp assignments at round start job selection
/datum/controller/subsystem/job/proc/handle_temp_assignments(mob/dead/new_player/player, datum/job/job)
	if(!player ||!player.mind || !job)
		return FALSE

	unassigned -= player
	if(!assigned_players_by_job[job.type])
		assigned_players_by_job[job.type] = list()

	if(player.temp_assignment)
		assigned_players_by_job[player.temp_assignment.type] -= player
		player.temp_assignment.current_positions--

	assigned_players_by_job[job.type] += player
	player.temp_assignment = job
	job.current_positions++
	JobDebug("h_t_a pass, Player: [player], Job: [job]")
	return TRUE

/// Handle antags as well as assigning people to their jobs
/datum/controller/subsystem/job/proc/handle_final_setup()
	var/sanity = 0
	var/max_sane_loops = length(subtypesof(/datum/round_event_control/antagonist/solo) - typesof(/datum/round_event_control/antagonist/solo/ghost)) //not exact, but its close enough
	pick_desired_roundstart()
	while(!handle_roundstart_antags() && !sanity >= max_sane_loops)
		sanity++
		pick_desired_roundstart()
		CHECK_TICK

	if(sanity >= max_sane_loops)
		if(SSgamemode.current_roundstart_event)
			message_admins("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) however \
							SSgamemode.current_roundstart_event([SSgamemode.current_roundstart_event]) is set, the roleset may not run correctly.")
			stack_trace("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) however \
						SSgamemode.current_roundstart_event([SSgamemode.current_roundstart_event]) is set.")
		else
			message_admins("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) with no set SSgamemode.current_roundstart_event, a roundstart roleset will not be run.")
			stack_trace("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) with no set SSgamemode.current_roundstart_event.")

	for(var/job in assigned_players_by_job)
		for(var/mob/dead/new_player/player in assigned_players_by_job[job])
			AssignRole(player, GetJobType(job), do_eligibility_checks = FALSE)
			assigned_players_by_job[job] -= player

	assigned_players_by_job = list()
	assignable_by_job = list()
	JobDebug("h_f_s pass")

/datum/controller/subsystem/job/proc/handle_roundstart_antags()
	if(!SSgamemode.current_roundstart_event)
		return FALSE

	var/list/candidates = SSgamemode.current_roundstart_event.get_candidates()

	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client
	if(length(cliented_list))
		mass_adjust_antag_rep(cliented_list, 1)

	var/list/weighted_candidates = return_antag_rep_weight(candidates)

	var/antag_selection_loops = SSgamemode.current_roundstart_event.get_antag_amount()
	for(var/i in 1 to antag_selection_loops)
		if(antag_selection_loops >= 100)
			JobDebug("h_r_a failed, antag_selection_loops went over 100")
			return FALSE
		if(!length(candidates))
			if(length(SSgamemode.roundstart_antag_minds) < SSgamemode.current_roundstart_event.base_antags) //we got below our min antags, reroll
				JobDebug("h_r_a failed, below required candidates for selected roundstart event")
				return FALSE
			break
		var/client/dead_client = pick_n_take_weighted(weighted_candidates)
		var/mob/dead/new_player/candidate = dead_client.mob
		if(!candidate.mind || !istype(candidate))
			antag_selection_loops++
			continue
		SSgamemode.roundstart_antag_minds += candidate.mind

	var/list/enemy_job_instances = list()
	for(var/enemy in SSgamemode.current_roundstart_event.enemy_roles)
		enemy_job_instances += GetJob(enemy)
	var/list/restricted_job_instances = list()
	for(var/role in SSgamemode.current_roundstart_event.restricted_roles)
		restricted_job_instances += GetJob(role)

	var/list/enemy_players = SSgamemode.current_roundstart_event.check_enemies(TRUE)
	var/enemy_count = length(enemy_players)
	for(var/datum/mind/player_mind in SSgamemode.roundstart_antag_minds)
		var/mob/dead/new_player/player = player_mind.current //we should always have a current mob as we get set from it
		if(!player.temp_assignment && !GiveRandomJob(player, TRUE, enemy_job_instances + restricted_job_instances) && !handle_temp_assignments(player, GetJobType(overflow_role)))
			SSgamemode.roundstart_antag_minds -= player_mind
			if(!length(weighted_candidates))
				if(length(SSgamemode.roundstart_antag_minds) < SSgamemode.current_roundstart_event.base_antags)
					JobDebug("h_r_a failed, removing unassigned antag player put us below current event minimum candidates")
					return FALSE
				continue
			var/mob/dead/new_player/candidate
			var/sanity = 0
			while(!candidate && length(weighted_candidates) && !sanity >= 100)
				sanity++
				candidate = pick_n_take_weighted(weighted_candidates)
				if(!candidate.mind || !istype(candidate))
					candidate = null
			if(!candidate)
				if(length(SSgamemode.roundstart_antag_minds) < SSgamemode.current_roundstart_event.base_antags)
					JobDebug("h_r_a failed, removing unassigned antag player put us below current event minimum candidates and we were unable to find a replacement")
					return FALSE
				else if(sanity >= 100)
					JobDebug("h_r_a error, sanity check went over limit while trying to find replacement antag player but it did not make us go under our minimum antag players")
					continue
				JobDebug("h_r_a error, we were unable to find a replacment for an unassigned antag player however we did not go under our minimum antag players")
				continue
			SSgamemode.roundstart_antag_minds += candidate.mind
			continue

		var/datum/job/enemy_job = enemy_job_instances.Find(player.temp_assignment)
		var/datum/job/restricted_job = restricted_job_instances.Find(player.temp_assignment)
		if(!enemy_job && !restricted_job)
			continue

		if(enemy_job && (enemy_count - 1) < SSgamemode.current_roundstart_event.required_enemies && !try_reassign_job(player, enemy_job_instances, \
																														restricted_job_instances, TRUE, enemy_players))
			JobDebug("h_r_a failed, an antag player was an enemy role and we could not find someone to replace them")
			return FALSE

		if(!try_reassign_job(player, enemy_job_instances, restricted_job_instances))
			JobDebug("h_r_a failed, we were unable to reassign an antag player with a restricted role")
			return FALSE
	return TRUE

/// Try and reassign the job of input player and return based on if we succeed or not, if need_new_enemy is passed then we will return FALSE if we cant find someone else to be an enemy
/datum/controller/subsystem/job/proc/try_reassign_job(mob/dead/new_player/player, list/enemy_jobs = list(), list/restricted_jobs = list(), need_new_enemy = FALSE, list/enemy_players)
	if(!GiveRandomJob(player, TRUE, enemy_jobs + restricted_jobs) && !handle_temp_assignments(player, GetJobType(overflow_role)))
		JobDebug("t_r_j failed, we were unable to give the reassigned player a new job, Player: [player]")
		return FALSE

	if(need_new_enemy)
		var/mob/dead/new_player/new_enemy_player
		for(var/datum/job/enemy_job in enemy_jobs)
			if(new_enemy_player)
				break
			if(!assignable_by_job[enemy_job.type])
				continue
			for(var/level in level_order)
				if(new_enemy_player)
					break
				var/list/antag_mobs = list()
				for(var/datum/mind/antag_mind in SSgamemode.roundstart_antag_minds)
					if(!antag_mind.current)
						continue
					antag_mobs += antag_mind.current
				for(var/mob/dead/new_player/possible_enemy in shuffle(assignable_by_job[enemy_job.type]["[level]"] - antag_mobs - enemy_players))
					new_enemy_player = possible_enemy
					handle_temp_assignments(new_enemy_player, enemy_job)
					break
		if(!new_enemy_player)
			JobDebug("t_r_j failed, we were unable to find someone to replace the enemy role of the reassigned player, Player: [player]")
			return FALSE
	return TRUE

//// Attempt to pick a roundstart ruleset to be our desired ruleset
/datum/controller/subsystem/job/proc/pick_desired_roundstart()
	var/static/list/valid_rolesets
	if(!valid_rolesets)
		valid_rolesets = list()
		valid_rolesets += SSgamemode.event_pools[EVENT_TRACK_ROLESET]

	valid_rolesets -= SSgamemode.current_roundstart_event
	var/player_count = 0
	for(var/job in assigned_players_by_job)
		player_count += length(assigned_players_by_job[job])

	var/list/actual_valid_rolesets = list()
	for(var/datum/round_event_control/antagonist/solo/roleset in valid_rolesets)
		if(!roleset.roundstart || !roleset.can_spawn_event(player_count))
			valid_rolesets -= roleset
		else
			actual_valid_rolesets[roleset] = roleset.weight
	valid_rolesets = actual_valid_rolesets

	if(SSgamemode.current_roundstart_event && (SSgamemode.current_roundstart_event in valid_rolesets))
		JobDebug("p_d_r failed, SSgamemode.current_roundstart_event in valid_rolesets")
		return

	if(!length(valid_rolesets))
		JobDebug("p_d_r failed, no valid_rolesets")
		return

	SSgamemode.current_roundstart_event = pick_weight(valid_rolesets)
	JobDebug("p_d_r pass, Selected Roleset: [SSgamemode.current_roundstart_event]")
