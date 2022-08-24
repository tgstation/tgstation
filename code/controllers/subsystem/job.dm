SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	/// List of all jobs.
	var/list/datum/job/all_occupations = list()
	/// List of jobs that can be joined through the starting menu.
	var/list/datum/job/joinable_occupations = list()
	/// Dictionary of all jobs, keys are titles.
	var/list/name_occupations = list()
	/// Dictionary of all jobs, keys are types.
	var/list/datum/job/type_occupations = list()

	/// Dictionary of jobs indexed by the experience type they grant.
	var/list/experience_jobs_map = list()

	/// List of all departments with joinable jobs.
	var/list/datum/job_department/joinable_departments = list()
	/// List of all joinable departments indexed by their typepath, sorted by their own display order.
	var/list/datum/job_department/joinable_departments_by_type = list()

	var/list/unassigned = list() //Players who need jobs
	var/initial_players_to_assign = 0 //used for checking against population caps

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()

	var/overflow_role = /datum/job/assistant

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

	/// Lazylist of mob:occupation_string pairs.
	var/list/dynamic_forced_occupations

	/**
	 * Keys should be assigned job roles. Values should be >= 1.
	 * Represents the chain of command on the station. Lower numbers mean higher priority.
	 * Used to give the Cap's Spare safe code to a an appropriate player.
	 * Assumed Captain is always the highest in the chain of command.
	 * See [/datum/controller/subsystem/ticker/proc/equip_characters]
	 */
	var/list/chain_of_command = list(
		JOB_CAPTAIN = 1,
		JOB_HEAD_OF_PERSONNEL = 2,
		JOB_RESEARCH_DIRECTOR = 3,
		JOB_CHIEF_ENGINEER = 4,
		JOB_CHIEF_MEDICAL_OFFICER = 5,
		JOB_HEAD_OF_SECURITY = 6,
		JOB_QUARTERMASTER = 7,
	)

	/// If TRUE, some player has been assigned Captaincy or Acting Captaincy at some point during the shift and has been given the spare ID safe code.
	var/assigned_captain = FALSE
	/// Whether the emergency safe code has been requested via a comms console on shifts with no Captain or Acting Captain.
	var/safe_code_requested = FALSE
	/// Timer ID for the emergency safe code request.
	var/safe_code_timer_id
	/// The loc to which the emergency safe code has been requested for delivery.
	var/turf/safe_code_request_loc

	/// Dictionary that maps job priorities to low/medium/high. Keys have to be number-strings as assoc lists cannot be indexed by integers. Set in setup_job_lists.
	var/list/job_priorities_to_strings

/datum/controller/subsystem/job/Initialize(timeofday)
	setup_job_lists()
	if(!length(all_occupations))
		SetupOccupations()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		LoadJobs()
	set_overflow_role(CONFIG_GET(string/overflow_job))
	return ..()


/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = ispath(new_overflow_role) ? GetJobType(new_overflow_role) : GetJob(new_overflow_role)
	if(!new_overflow)
		JobDebug("Failed to set new overflow role: [new_overflow_role]")
		CRASH("set_overflow_role failed | new_overflow_role: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.allow_bureaucratic_error = FALSE
	new_overflow.spawn_positions = cap
	new_overflow.total_positions = cap

	if(new_overflow.type == overflow_role)
		return
	var/datum/job/old_overflow = GetJobType(overflow_role)
	old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
	old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
	old_overflow.total_positions = initial(old_overflow.total_positions)
	overflow_role = new_overflow.type
	JobDebug("Overflow role set to : [new_overflow.type]")


/datum/controller/subsystem/job/proc/SetupOccupations()
	name_occupations = list()
	type_occupations = list()

	var/list/all_jobs = subtypesof(/datum/job)
	if(!length(all_jobs))
		all_occupations = list()
		joinable_occupations = list()
		joinable_departments = list()
		joinable_departments_by_type = list()
		experience_jobs_map = list()
		to_chat(world, span_boldannounce("Error setting up jobs, no job datums found"))
		return FALSE

	var/list/new_all_occupations = list()
	var/list/new_joinable_occupations = list()
	var/list/new_joinable_departments = list()
	var/list/new_joinable_departments_by_type = list()
	var/list/new_experience_jobs_map = list()

	for(var/job_type in all_jobs)
		var/datum/job/job = new job_type()
		if(!job.config_check())
			continue
		if(!job.map_check()) //Even though we initialize before mapping, this is fine because the config is loaded at new
			log_job_debug("Removed [job.title] due to map config")
			continue
		new_all_occupations += job
		name_occupations[job.title] = job
		type_occupations[job_type] = job
		if(job.job_flags & JOB_NEW_PLAYER_JOINABLE)
			new_joinable_occupations += job
			if(!LAZYLEN(job.departments_list))
				var/datum/job_department/department = new_joinable_departments_by_type[/datum/job_department/undefined]
				if(!department)
					department = new /datum/job_department/undefined()
					new_joinable_departments_by_type[/datum/job_department/undefined] = department
				department.add_job(job)
				continue
			for(var/department_type in job.departments_list)
				var/datum/job_department/department = new_joinable_departments_by_type[department_type]
				if(!department)
					department = new department_type()
					new_joinable_departments_by_type[department_type] = department
				department.add_job(job)

	sortTim(new_all_occupations, /proc/cmp_job_display_asc)
	for(var/datum/job/job as anything in new_all_occupations)
		if(!job.exp_granted_type)
			continue
		new_experience_jobs_map[job.exp_granted_type] += list(job)

	sortTim(new_joinable_departments_by_type, /proc/cmp_department_display_asc, associative = TRUE)
	for(var/department_type in new_joinable_departments_by_type)
		var/datum/job_department/department = new_joinable_departments_by_type[department_type]
		sortTim(department.department_jobs, /proc/cmp_job_display_asc)
		new_joinable_departments += department
		if(department.department_experience_type)
			new_experience_jobs_map[department.department_experience_type] = department.department_jobs.Copy()

	all_occupations = new_all_occupations
	joinable_occupations = sortTim(new_joinable_occupations, /proc/cmp_job_display_asc)
	joinable_departments = new_joinable_departments
	joinable_departments_by_type = new_joinable_departments_by_type
	experience_jobs_map = new_experience_jobs_map

	return TRUE


/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!length(all_occupations))
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	RETURN_TYPE(/datum/job)
	if(!length(all_occupations))
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/get_department_type(department_type)
	if(!length(all_occupations))
		SetupOccupations()
	return joinable_departments_by_type[department_type]

/**
 * Assigns the given job role to the player.
 *
 * Arguments:
 * * player - The player to assign the job to
 * * job - The job to assign
 * * latejoin - Set to TRUE if this is a latejoin role assignment.
 * * do_eligibility_checks - Set to TRUE to conduct all job eligibility tests and reject on failure. Set to FALSE if job eligibility has been tested elsewhere and they can be safely skipped.
 */
/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE)
	JobDebug("Running AR, Player: [player], Job: [isnull(job) ? "null" : job], LateJoin: [latejoin]")
	if(!player?.mind || !job)
		JobDebug("AR has failed, player has no mind or job is null, Player: [player], Rank: [isnull(job) ? "null" : job.type]")
		return FALSE

	if(do_eligibility_checks && (check_job_eligibility(player, job, "AR", add_job_to_log = TRUE) != JOB_AVAILABLE))
		return FALSE

	JobDebug("Player: [player] is now Rank: [job.title], JCP:[job.current_positions], JPL:[latejoin ? job.total_positions : job.spawn_positions]")
	player.mind.set_assigned_role(job)
	unassigned -= player
	job.current_positions++
	return TRUE

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level)
	JobDebug("Running FOC, Job: [job], Level: [job_priority_level_to_string(level)]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(!player)
			JobDebug("FOC player no longer exists.")
			continue
		if(!player.client)
			JobDebug("FOC player client no longer exists, Player: [player]")
			continue
		// Initial screening check. Does the player even have the job enabled, if they do - Is it at the correct priority level?
		var/player_job_level = player.client?.prefs.job_preferences[job.title]
		if(isnull(player_job_level))
			JobDebug("FOC player job not enabled, Player: [player]")
			continue
		else if(player_job_level != level)
			JobDebug("FOC player job enabled at wrong level, Player: [player], TheirLevel: [job_priority_level_to_string(player_job_level)], ReqLevel: [job_priority_level_to_string(level)]")
			continue

		// This check handles its own output to JobDebug.
		if(check_job_eligibility(player, job, "FOC", add_job_to_log = FALSE) != JOB_AVAILABLE)
			continue

		// They have the job enabled, at this priority level, with no restrictions applying to them.
		JobDebug("FOC pass, Player: [player], Level: [job_priority_level_to_string(level)]")
		candidates += player
	return candidates


/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job as anything in shuffle(joinable_occupations))
		if(QDELETED(player))
			JobDebug("GRJ player is deleted, aborting")
			break

		if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
			JobDebug("GRJ job lacks spawn positions to be eligible, Player: [player], Job: [job]")
			continue

		if(istype(job, GetJobType(overflow_role))) // We don't want to give him assistant, that's boring!
			JobDebug("GRJ skipping overflow role, Player: [player], Job: [job]")
			continue

		if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //If you want a command position, select it!
			JobDebug("GRJ skipping command role, Player: [player], Job: [job]")
			continue

		// This check handles its own output to JobDebug.
		if(check_job_eligibility(player, job, "GRJ", add_job_to_log = TRUE) != JOB_AVAILABLE)
			continue

		if(AssignRole(player, job, do_eligibility_checks = FALSE))
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			return TRUE

		JobDebug("GRJ Player eligible but AssignRole failed, Player: [player], Job: [job]")


/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player?.mind)
			continue
		player.mind.set_assigned_role(GetJobType(/datum/job/unassigned))
		player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return


/**
 * Will try to select a head, ignoring ALL non-head preferences for every level until.
 *
 * Basically tries to ensure there is at least one head in every shift if anyone has that job preference enabled at all.
 */
/datum/controller/subsystem/job/proc/FillHeadPosition()
	var/datum/job_department/command_department = get_department_type(/datum/job_department/command)
	if(!command_department)
		return FALSE
	for(var/level in level_order)
		for(var/datum/job/job as anything in command_department.department_jobs)
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			// Eligibility checks done as part of FindOccupationCandidates.
			if(AssignRole(candidate, job, do_eligibility_checks = FALSE))
				return TRUE
	return FALSE


/**
 * Attempts to fill out all possible head positions for players with that job at a a given job priority level.
 *
 * Arguments:
 * * level - One of the JP_LOW, JP_MEDIUM or JP_HIGH defines. Attempts to find candidates with head jobs at this priority only.
 */
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	var/datum/job_department/command_department = get_department_type(/datum/job_department/command)
	if(!command_department)
		return
	for(var/datum/job/job as anything in command_department.department_jobs)
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = pick(candidates)
		// Eligibility checks done as part of FindOccupationCandidates
		AssignRole(candidate, job, do_eligibility_checks = FALSE)

/// Attempts to fill out all available AI positions.
/datum/controller/subsystem/job/proc/fill_ai_positions()
	var/datum/job/ai_job = GetJob(JOB_AI)
	if(!ai_job)
		return
	// In byond for(in to) loops, the iteration is inclusive so we need to stop at ai_job.total_positions - 1
	for(var/i in ai_job.current_positions to ai_job.total_positions - 1)
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(ai_job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				// Eligibility checks done as part of FindOccupationCandidates
				if(AssignRole(candidate, GetJobType(/datum/job/ai), do_eligibility_checks = FALSE))
					break


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_DIVIDED)

	//Get the players who are ready
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences() && player.mind && is_unassigned_job(player.mind.assigned_role))
			unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")

	//Scale number of open security officer slots to population
	setup_officer_positions()

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(mat > unassigned.len)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	// Dynamic has picked a ruleset that requires enforcing some jobs before others.
	JobDebug("DO, Assigning Priority Positions: [length(dynamic_forced_occupations)]")
	assign_priority_positions()

	//People who wants to be the overflow role, sure, go on.
	JobDebug("DO, Running Overflow Check 1")
	var/datum/job/overflow_datum = GetJobType(overflow_role)
	var/list/overflow_candidates = FindOccupationCandidates(overflow_datum, JP_LOW)
	JobDebug("AC1, Candidates: [overflow_candidates.len]")
	for(var/mob/dead/new_player/player in overflow_candidates)
		JobDebug("AC1 pass, Player: [player]")
		// Eligibility checks done as part of FindOccupationCandidates
		AssignRole(player, GetJobType(overflow_role), do_eligibility_checks = FALSE)
		overflow_candidates -= player
	JobDebug("DO, AC1 end")

	//Select one head
	JobDebug("DO, Running Head Check")
	FillHeadPosition()
	JobDebug("DO, Head Check end")

	// Fill out any remaining AI positions.
	JobDebug("DO, Running AI Check")
	fill_ai_positions()
	JobDebug("DO, AI Check end")

	//Other jobs are now checked
	JobDebug("DO, Running standard job assignment")
	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(joinable_occupations)
	for(var/level in level_order)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)
			if(PopcapReached())
				RejectPlayer(player)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					JobDebug("FOC invalid/null job in occupations, Player: [player], Job: [job]")
					shuffledoccupations -= job
					continue

				// Make sure the job isn't filled. If it is, remove it from the list so it doesn't get checked again.
				if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
					JobDebug("FOC job filled and not overflow, Player: [player], Job: [job], Current: [job.current_positions], Limit: [job.spawn_positions]")
					shuffledoccupations -= job
					continue

				// Filter any job that doesn't fit the current level.
				var/player_job_level = player.client?.prefs.job_preferences[job.title]
				if(isnull(player_job_level))
					JobDebug("FOC player job not enabled, Player: [player]")
					continue
				else if(player_job_level != level)
					JobDebug("FOC player job enabled but at different level, Player: [player], TheirLevel: [job_priority_level_to_string(player_job_level)], ReqLevel: [job_priority_level_to_string(level)]")
					continue

				if(check_job_eligibility(player, job, "DO", add_job_to_log = TRUE) != JOB_AVAILABLE)
					continue

				JobDebug("DO pass, Player: [player], Level:[level], Job:[job.title]")
				AssignRole(player, job, do_eligibility_checks = FALSE)
				unassigned -= player
				break

	JobDebug("DO, Ending standard job assignment")

	JobDebug("DO, Handle unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/player in unassigned)
		HandleUnassigned(player)
	JobDebug("DO, Ending handle unassigned.")

	JobDebug("DO, Handle unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!GiveRandomJob(player))
			if(!AssignRole(player, GetJobType(overflow_role))) //If everything is already filled, make them an assistant
				JobDebug("DO, Forced antagonist could not be assigned any random job or the overflow role. DivideOccupations failed.")
				JobDebug("---------------------------------------------------")
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll
	JobDebug("DO, Ending handle unrejectable unassigned")

	JobDebug("All divide occupations tasks completed.")
	JobDebug("---------------------------------------------------")

	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	var/jobless_role = player.client.prefs.read_preference(/datum/preference/choiced/jobless_role)

	if(PopcapReached())
		RejectPlayer(player)
		return

	switch (jobless_role)
		if (BEOVERFLOW)
			var/datum/job/overflow_role_datum = GetJobType(overflow_role)

			if(check_job_eligibility(player, overflow_role_datum, debug_prefix = "HU", add_job_to_log = TRUE) != JOB_AVAILABLE)
				RejectPlayer(player)
				return

			if(!AssignRole(player, overflow_role_datum, do_eligibility_checks = FALSE))
				RejectPlayer(player)
				return
		if (BERANDOMJOB)
			if(!GiveRandomJob(player))
				RejectPlayer(player)
				return
		if (RETURNTOLOBBY)
			RejectPlayer(player)
			return
		else //Something gone wrong if we got here.
			var/message = "HU: [player] fell through handling unassigned"
			JobDebug(message)
			log_game(message)
			message_admins(message)
			RejectPlayer(player)


//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/equipping, datum/job/job, client/player_client)
	equipping.job = job.title

	SEND_SIGNAL(equipping, COMSIG_JOB_RECEIVED, job)

	equipping.mind?.set_assigned_role(job)

	if(player_client)
		to_chat(player_client, "<span class='infoplain'><b>You are the [job.title].</b></span>")

	equipping.on_job_equipping(job)

	job.announce_job(equipping)

	if(player_client?.holder)
		if(CONFIG_GET(flag/auto_deadmin_players) || (player_client.prefs?.toggles & DEADMIN_ALWAYS))
			player_client.holder.auto_deadmin()
		else
			handle_auto_deadmin_roles(player_client, job.title)

	if(player_client)
		to_chat(player_client, "<span class='infoplain'><b>As the [job.title] you answer directly to [job.supervisors]. Special circumstances may change this.</b></span>")

	job.radio_help_message(equipping)

	if(player_client)
		if(job.req_admin_notify)
			to_chat(player_client, "<span class='infoplain'><b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b></span>")
		if(CONFIG_GET(number/minimal_access_threshold))
			to_chat(player_client, span_notice("<B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B>"))

		var/related_policy = get_policy(job.title)
		if(related_policy)
			to_chat(player_client, related_policy)

	if(ishuman(equipping))
		var/mob/living/carbon/human/wageslave = equipping
		wageslave.mind.add_memory(MEMORY_ACCOUNT, list(DETAIL_ACCOUNT_ID = wageslave.account_id), story_value = STORY_VALUE_SHIT, memory_flags = MEMORY_FLAG_NOLOCATION)


	job.after_spawn(equipping, player_client)


/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJob(rank)

	var/timegate_expired = FALSE
	// allow only forcing deadminning in the first X seconds of the round if auto_deadmin_timegate is set in config
	var/timegate = CONFIG_GET(number/auto_deadmin_timegate)
	if(timegate && (world.time - SSticker.round_start_time > timegate))
		timegate_expired = TRUE

	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && ((CONFIG_GET(flag/auto_deadmin_heads) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && ((CONFIG_GET(flag/auto_deadmin_security) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_SECURITY)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && ((CONFIG_GET(flag/auto_deadmin_silicons) && !timegate_expired) || (C.prefs?.toggles & DEADMIN_POSITION_SILICON))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob(JOB_SECURITY_OFFICER)
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	var/ssc = CONFIG_GET(number/security_scaling_coeff)
	if(ssc > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len / ssc))) //Scale between configured minimum and 12 officers
			JobDebug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions

	//Spawn some extra eqipment lockers if we have more than 5 officers
	var/equip_needed = J.total_positions
	if(equip_needed < 0) // -1: infinite available slots
		equip_needed = 12
	for(var/i=equip_needed-5, i>0, i--)
		if(GLOB.secequipment.len)
			var/spawnloc = GLOB.secequipment[1]
			new /obj/structure/closet/secure_closet/security/sec(spawnloc)
			GLOB.secequipment -= spawnloc
		else //We ran out of spare locker spawns!
			break


/datum/controller/subsystem/job/proc/LoadJobs()
	var/jobstext = file2text("[global.config.directory]/jobs.txt")
	for(var/datum/job/job as anything in joinable_occupations)
		var/regex/jobs = new("[job.title]=(-1|\\d+),(-1|\\d+)")
		jobs.Find(jobstext)
		job.total_positions = text2num(jobs.group[1])
		job.spawn_positions = text2num(jobs.group[2])

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job as anything in joinable_occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/player = i
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && is_unassigned_job(player.mind.assigned_role)))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.title) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			switch(player.client.prefs.job_preferences[job.title])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<span class='infoplain'><b>You have failed to qualify for any job you desired.</b></span>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.all_occupations
	sleep(20)
	for (var/datum/job/job as anything in oldjobs)
		INVOKE_ASYNC(src, .proc/RecoverJob, job)

/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.title)
	if (!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions

/atom/proc/JoinPlayerHere(mob/joining_mob, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	joining_mob.forceMove(get_turf(src))

/obj/structure/chair/JoinPlayerHere(mob/joining_mob, buckle)
	. = ..()
	// Placing a mob in a chair will attempt to buckle it, or else fall back to default.
	if(buckle && isliving(joining_mob))
		buckle_mob(joining_mob, FALSE, FALSE)

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && !is_unassigned_job(M.mind.assigned_role) && length(GLOB.jobspawn_overrides[M.mind.assigned_role.title])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role.title])
		destination.JoinPlayerHere(M, FALSE)
		return TRUE

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return TRUE

	destination = get_last_resort_spawn_points()
	destination.JoinPlayerHere(M, buckle)


/datum/controller/subsystem/job/proc/get_last_resort_spawn_points()
	//bad mojo
	var/area/shuttle/arrival/arrivals_area = GLOB.areas_by_type[/area/shuttle/arrival]
	if(arrivals_area)
		//first check if we can find a chair
		var/obj/structure/chair/shuttle_chair = locate() in arrivals_area
		if(shuttle_chair)
			return shuttle_chair

		//last hurrah
		var/list/turf/available_turfs = list()
		for(var/turf/arrivals_turf in arrivals_area)
			if(!arrivals_turf.is_blocked_turf(TRUE))
				available_turfs += arrivals_turf
		if(length(available_turfs))
			return pick(available_turfs)

	//pick an open spot on arrivals and dump em
	var/list/arrivals_turfs = shuffle(get_area_turfs(/area/shuttle/arrival))
	if(length(arrivals_turfs))
		for(var/turf/arrivals_turf in arrivals_turfs)
			if(!arrivals_turf.is_blocked_turf(TRUE))
				return arrivals_turf
		//last chance, pick ANY spot on arrivals and dump em
		return pick(arrivals_turfs)

	stack_trace("Unable to find last resort spawn point.")
	return GET_ERROR_ROOM


///Lands specified mob at a random spot in the hallways
/datum/controller/subsystem/job/proc/DropLandAtRandomHallwayPoint(mob/living/living_mob)
	var/turf/spawn_turf = get_safe_random_station_turf(typesof(/area/station/hallway))

	if(!spawn_turf)
		SendToLateJoin(living_mob)
	else
		var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
		living_mob.forceMove(toLaunch)
		new /obj/effect/pod_landingzone(spawn_turf, toLaunch)

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.stat != DEAD && (player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
			. += player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			. += player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.stat != DEAD && (player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			. += player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(player.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			. += player.mind

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)

/// Builds various lists of jobs based on station, centcom and additional jobs with icons associated with them.
/datum/controller/subsystem/job/proc/setup_job_lists()
	job_priorities_to_strings = list(
		"[JP_LOW]" = "Low Priority",
		"[JP_MEDIUM]" = "Medium Priority",
		"[JP_HIGH]" = "High Priority",
	)

/obj/item/paper/fluff/spare_id_safe_code
	name = "Nanotrasen-Approved Spare ID Safe Code"
	desc = "Proof that you have been approved for Captaincy, with all its glory and all its horror."

/obj/item/paper/fluff/spare_id_safe_code/Initialize(mapload)
	var/safe_code = SSid_access.spare_id_safe_code
	default_raw_text = "Captain's Spare ID safe code combination: [safe_code ? safe_code : "\[REDACTED\]"]<br><br>The spare ID can be found in its dedicated safe on the bridge.<br><br>If your job would not ordinarily have Head of Staff access, your ID card has been specially modified to possess it."
	return ..()

/obj/item/paper/fluff/emergency_spare_id_safe_code
	name = "Emergency Spare ID Safe Code Requisition"
	desc = "Proof that nobody has been approved for Captaincy. A skeleton key for a skeleton shift."

/obj/item/paper/fluff/emergency_spare_id_safe_code/Initialize(mapload)
	var/safe_code = SSid_access.spare_id_safe_code
	default_raw_text = "Captain's Spare ID safe code combination: [safe_code ? safe_code : "\[REDACTED\]"]<br><br>The spare ID can be found in its dedicated safe on the bridge."
	return ..()

/datum/controller/subsystem/job/proc/promote_to_captain(mob/living/carbon/human/new_captain, acting_captain = FALSE)
	var/id_safe_code = SSid_access.spare_id_safe_code

	if(!id_safe_code)
		CRASH("Cannot promote [new_captain.real_name] to Captain, there is no id_safe_code.")

	var/paper = new /obj/item/paper/fluff/spare_id_safe_code()
	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS
	)
	var/where = new_captain.equip_in_one_of_slots(paper, slots, FALSE) || "at your feet"

	if(acting_captain)
		to_chat(new_captain, span_notice("Due to your position in the chain of command, you have been promoted to Acting Captain. You can find in important note about this [where]."))
	else
		to_chat(new_captain, span_notice("You can find the code to obtain your spare ID from the secure safe on the Bridge [where]."))

	// Force-give their ID card bridge access.
	var/obj/item/id_slot = new_captain.get_item_by_slot(ITEM_SLOT_ID)
	if(id_slot)
		var/obj/item/card/id/id_card = id_slot.GetID()
		if(!(ACCESS_COMMAND in id_card.access))
			id_card.add_wildcards(list(ACCESS_COMMAND), mode=FORCE_ADD_ALL)

	assigned_captain = TRUE

/// Send a drop pod containing a piece of paper with the spare ID safe code to loc
/datum/controller/subsystem/job/proc/send_spare_id_safe_code(loc)
	new /obj/effect/pod_landingzone(loc, /obj/structure/closet/supplypod/centcompod, new /obj/item/paper/fluff/emergency_spare_id_safe_code())
	safe_code_timer_id = null
	safe_code_request_loc = null

/// Blindly assigns the required roles to every player in the dynamic_forced_occupations list.
/datum/controller/subsystem/job/proc/assign_priority_positions()
	for(var/mob/new_player in dynamic_forced_occupations)
		// Eligibility checks already carried out as part of the dynamic ruleset trim_candidates proc.area
		// However no guarantee of game state between then and now, so don't skip eligibility checks on AssignRole.
		AssignRole(new_player, GetJob(dynamic_forced_occupations[new_player]))

/// Takes a job priority #define such as JP_LOW and gets its string representation for logging.
/datum/controller/subsystem/job/proc/job_priority_level_to_string(priority)
	return job_priorities_to_strings["[priority]"] || "Undefined Priority \[[priority]\]"

/**
 * Runs a standard suite of eligibility checks to make sure the player can take the reqeusted job.
 *
 * Checks:
 * * Role bans
 * * How many days old the player account is
 * * Whether the player has the required hours in other jobs to take that role
 * * If the job is in the mind's restricted roles, for example if they have an antag datum that's incompatible with certain roles.
 *
 * Arguments:
 * * player - The player to check for job eligibility.
 * * possible_job - The job to check for eligibility against.
 * * debug_prefix - Logging prefix for the JobDebug log entries. For example, GRJ during GiveRandomJob or DO during DivideOccupations.
 * * add_job_to_log - If TRUE, appends the job type to the log entry. If FALSE, does not. Set to FALSE when check is part of iterating over players for a specific job, set to TRUE when check is part of iterating over jobs for a specific player and you don't want extra log entry spam.
 */
/datum/controller/subsystem/job/proc/check_job_eligibility(mob/dead/new_player/player, datum/job/possible_job, debug_prefix = "", add_job_to_log = FALSE)
	if(!player.mind)
		JobDebug("[debug_prefix] player has no mind, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	if(possible_job.title in player.mind.restricted_roles)
		JobDebug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ANTAG_INCOMPAT, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ANTAG_INCOMPAT

	if(!possible_job.player_old_enough(player.client))
		JobDebug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ACCOUNTAGE, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ACCOUNTAGE

	var/required_playtime_remaining = possible_job.required_playtime_remaining(player.client)
	if(required_playtime_remaining)
		JobDebug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_PLAYTIME, possible_job.title)], Player: [player], MissingTime: [required_playtime_remaining][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_PLAYTIME

	// Run the banned check last since it should be the rarest check to fail and can access the database.
	if(is_banned_from(player.ckey, possible_job.title))
		JobDebug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_BANNED, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_BANNED

	// Need to recheck the player exists after is_banned_from since it can query the DB which may sleep.
	if(QDELETED(player))
		JobDebug("[debug_prefix] player is qdeleted, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	return JOB_AVAILABLE
