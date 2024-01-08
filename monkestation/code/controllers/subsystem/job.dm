/datum/controller/subsystem/job
	/// Assoc list of new players keyed to the type of what job they will currently get
	var/list/assigned_players_by_job = list()
	/// Nested assoc list of job types with values of lists of players who are viable for that job keyed to what priority level that has player the job set to in their prefs
	var/list/assignable_by_job = list()

/datum/controller/subsystem/job/proc/handle_temp_assignments(mob/dead/new_player/player, datum/job/job)
	if(!player ||!player.mind || !job)
		return FALSE

	unassigned -= player
	if(!assigned_players_by_job[job.type])
		assigned_players_by_job[job.type] = list()

	if(player.temp_assignment)
		assigned_players_by_job[player.temp_assignment.type] -= player

	assigned_players_by_job[job.type] += player
	player.temp_assignment = job
	return TRUE

/// Handle antags as well as assigning people to their jobs
/datum/controller/subsystem/job/proc/handle_final_setup()
	var/sanity = 0
	var/max_sane_loops = length(subtypesof(/datum/round_event_control/antagonist/solo) - typesof(/datum/round_event_control/antagonist/solo/ghost))
	UNTIL(handle_roundstart_antags() || sanity >= max_sane_loops)
		sanity++
		pick_desired_roundstart()

	if(sanity >= max_sane_loops)
		if(SSgamemode.current_roundstart_event)
			message_admins("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) however \
							SSgamemode.current_roundstart_event([SSgamemode.current_roundstart_event]) is set, the roleset may not run correctly!")
			stack_trace("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) however \
						SSgamemode.current_roundstart_event([SSgamemode.current_roundstart_event]) is set.")
		else
			message_admins("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) with no set SSgamemode.current_roundstart_event, a roundstart roleset will not be run.")
			stack_trace("The SSjob handle_roundstart_antags() loop ran too many times([sanity]) with no set SSgamemode.current_roundstart_event.")

/datum/controller/subsystem/job/proc/handle_roundstart_antags()
	if(!SSgamemode.current_roundstart_event)
		return FALSE

	var/list/candidates = SSgamemode.current_roundstart_event.get_candidates()
	for(var/i in 1 to SSgamemode.current_roundstart_event.get_antag_count())
		if(!length(candidates))
			if(length(SSgamemode.roundstart_antag_players) < SSgamemode.current_roundstart_event.base_antags) //we got below our min antags, reroll
				return FALSE
			break
		SSgamemode.roundstart_antag_players += pick_n_take(candidates)

	var/list/enemy_job_instances = list()
	for(var/enemy in SSgamemode.current_roundstart_event.enemy_roles)
		enemy_job_instances += GetJob(enemy)
	var/list/restricted_job_instances = list()
	for(var/role in SSgamemode.current_roundstart_event.restricted_roles)
		enemy_job_instances += GetJob(role)

	var/enemy_count = SSgamemode.current_roundstart_event.check_enemies(TRUE)
	for(var/mob/dead/new_player/player in SSgamemode.roundstart_antag_players)
		if(!player.temp_assignment && !GiveRandomJob(player, TRUE) && !handle_temp_assignments(player, GetJobType(overflow_role)))
			SSgamemode.roundstart_antag_players -= player
			if(!length(candidates))
				if(length(SSgamemode.roundstart_antag_players) < SSgamemode.current_roundstart_event.base_antags)
					return FALSE
				continue
			SSgamemode.roundstart_antag_players += pick_n_take(candidates)
			continue

		var/datum/job/enemy_job = enemy_job_instances.Find(player.temp_assignment)
		var/datum/job/restricted_job = restricted_job_instances.Find(player.temp_assignment)
		if(!enemy_job && !restricted_job)
			continue

		if(enemy_job && (enemy_count - 1) < SSgamemode.current_roundstart_event.required_enemies && !try_reassign_job(player, enemy_job, TRUE))
			return FALSE

		if(!try_reassign_job(player, enemy_job))
			return FALSE

/// Try and reassign the job of input player and return based on if we succeed or not, if required_job is set then we will return FALSE if we cant find someone else to fill the old job
/datum/controller/subsystem/job/proc/try_reassign_job(mob/dead/new_player/player, datum/job/job_to_reassign, required_job = FALSE)
	for(var/level in level_order)

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
	for(var/datum/round_event_control/antagonist/solo/roleset in valid_rolesets)
		if(!roleset.roundstart || !roleset.can_spawn_event(player_count))
			valid_rolesets -= roleset

	if(SSgamemode.current_roundstart_event && valid_rolesets.Find(SSgamemode.current_roundstart_event))
		return TRUE

	if(!length(valid_rolesets)) //might need to make this use exact return values
		return TRUE

	SSgamemode.current_roundstart_event = pick(valid_rolesets)
	return FALSE
