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
	// Whether to run divide_occupations pure so that there are no side-effects from calling it other than
	// a player's assigned_role being set to some value.
	var/run_divide_occupation_pure = FALSE

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()

	var/overflow_role = /datum/job/assistant

	var/list/level_order = list(JP_HIGH, JP_MEDIUM, JP_LOW)

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

	/// Are we using the old job config system (txt) or the new job config system (TOML)? IF we are going to use the txt file, then we are in "legacy mode", and this will flip to TRUE.
	var/legacy_mode = FALSE

	/// List of job config datum singletons.
	var/list/job_config_datum_singletons = list()

	/// This is just the message we prepen and put into all of the config files to ensure documentation. We use this in more than one place, so let's put it in the SS to make life a bit easier.
	var/config_documentation = "## This is the configuration file for the job system.\n## This will only be enabled when the config flag LOAD_JOBS_FROM_TXT is enabled.\n\
	## We use a system of keys here that directly correlate to the job, just to ensure they don't desync if we choose to change the name of a job.\n## You are able to change (as of now) five (six if the job is a command head) different variables in this file.\n\
	## Total Positions are how many job slots you get in a shift, Spawn Positions are how many you get that load in at spawn. If you set this to -1, it is unrestricted.\n## Playtime Requirements is in minutes, and the job will unlock when a player reaches that amount of time.\n\
	## However, that can be superseded by Required Account Age, which is a time in days that you need to have had an account on the server for.\n\
	## Also there is a required character age in years. It prevents player from joining as this job, if their character's age as is lower than required. Setting it to 0 means it is turned off for this job.\n\
	## Lastly there's Human Authority Whitelist Setting. You can set it to either \"HUMANS_ONLY\" or \"NON_HUMANS_ALLOWED\". Check the \"Human Authority\" setting on the game_options file to know which you should choose. Note that this entry only appears on jobs that are marked as heads of staff.\n\n\
	## As time goes on, more config options may be added to this file.\n\
	## You can use the admin verb 'Generate Job Configuration' in-game to auto-regenerate this config as a downloadable file without having to manually edit this file if we add more jobs or more things you can edit here.\n\
	## It will always respect prior-existing values in the config, but will appropriately add more fields when they generate.\n## It's strongly advised you create your own version of this file rather than use the one provisioned on the codebase.\n\n\
	## The game will not read any line that is commented out with a '#', as to allow you to defer to codebase defaults.\n## If you want to override the codebase values, add the value and then uncomment that line by removing the # from the job key's name.\n\
	## Ensure that the key is flush, do not introduce any whitespaces when you uncomment a key. For example:\n## \"# Total Positions\" should always be changed to \"Total Positions\", no additional spacing.\n\
	## Best of luck editing!\n"

/datum/controller/subsystem/job/Initialize()
	setup_job_lists()
	job_config_datum_singletons = generate_config_singletons() // we set this up here regardless in case someone wants to use the verb to generate the config file.
	if(!length(all_occupations))
		setup_occupations()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		load_jobs_from_config()
	set_overflow_role(CONFIG_GET(string/overflow_job)) // this must always go after load_jobs_from_config() due to how the legacy systems operate, this always takes precedent.
	return SS_INIT_SUCCESS

/// Returns a list of jobs that we are allowed to fuck with during random events
/datum/controller/subsystem/job/proc/get_valid_overflow_jobs()
	var/static/list/overflow_jobs
	if (!isnull(overflow_jobs))
		return overflow_jobs

	overflow_jobs = list()
	for (var/datum/job/check_job in joinable_occupations)
		if (!check_job.allow_bureaucratic_error)
			continue
		overflow_jobs += check_job
	return overflow_jobs

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = ispath(new_overflow_role) ? get_job_type(new_overflow_role) : get_job(new_overflow_role)
	if(!new_overflow)
		job_debug("SET_OVRFLW: Failed to set new overflow role: [new_overflow_role]")
		CRASH("set_overflow_role failed | new_overflow_role: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.allow_bureaucratic_error = FALSE
	new_overflow.spawn_positions = cap
	new_overflow.total_positions = cap
	new_overflow.job_flags |= JOB_CANNOT_OPEN_SLOTS

	if(new_overflow.type == overflow_role)
		return
	var/datum/job/old_overflow = get_job_type(overflow_role)
	old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
	old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
	old_overflow.total_positions = initial(old_overflow.total_positions)
	if(!(initial(old_overflow.job_flags) & JOB_CANNOT_OPEN_SLOTS))
		old_overflow.job_flags &= ~JOB_CANNOT_OPEN_SLOTS
	overflow_role = new_overflow.type
	job_debug("SET_OVRFLW: Overflow role set to: [new_overflow.type]")

/datum/controller/subsystem/job/proc/setup_occupations()
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
		for(var/alt_title in job.alternate_titles)
			name_occupations[alt_title] = job
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

	sortTim(new_all_occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	for(var/datum/job/job as anything in new_all_occupations)
		if(!job.exp_granted_type)
			continue
		new_experience_jobs_map[job.exp_granted_type] += list(job)

	sortTim(new_joinable_departments_by_type, GLOBAL_PROC_REF(cmp_department_display_asc), associative = TRUE)
	for(var/department_type in new_joinable_departments_by_type)
		var/datum/job_department/department = new_joinable_departments_by_type[department_type]
		sortTim(department.department_jobs, GLOBAL_PROC_REF(cmp_job_display_asc))
		new_joinable_departments += department
		if(department.department_experience_type)
			new_experience_jobs_map[department.department_experience_type] = department.department_jobs.Copy()

	all_occupations = new_all_occupations
	joinable_occupations = sortTim(new_joinable_occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	joinable_departments = new_joinable_departments
	joinable_departments_by_type = new_joinable_departments_by_type
	experience_jobs_map = new_experience_jobs_map

	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_SETUP)

	return TRUE


/datum/controller/subsystem/job/proc/get_job(rank)
	if(!length(all_occupations))
		setup_occupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/get_job_type(jobtype)
	RETURN_TYPE(/datum/job)
	if(!length(all_occupations))
		setup_occupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/get_department_type(department_type)
	if(!length(all_occupations))
		setup_occupations()
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
/datum/controller/subsystem/job/proc/assign_role(mob/dead/new_player/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE)
	job_debug("AR: Running, Player: [player], Job: [isnull(job) ? "null" : job], LateJoin: [latejoin]")
	if(!player?.mind || !job)
		job_debug("AR: Failed, player has no mind or job is null. Player: [player], Rank: [isnull(job) ? "null" : job.type]")
		return FALSE

	if(do_eligibility_checks && (check_job_eligibility(player, job, "AR", add_job_to_log = TRUE) != JOB_AVAILABLE))
		return FALSE

	job_debug("AR: Role now set and assigned - [player] is [job.title], JCP:[job.current_positions], JPL:[latejoin ? job.total_positions : job.spawn_positions]")
	player.mind.set_assigned_role(job)
	unassigned -= player
	job.current_positions++
	return TRUE

/datum/controller/subsystem/job/proc/find_occupation_candidates(datum/job/job, level = 0)
	job_debug("FOC: Now running, Job: [job], Level: [job_priority_level_to_string(level)]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(!player)
			job_debug("FOC: Player no longer exists.")
			continue

		if(!player.client)
			job_debug("FOC: Player client no longer exists, Player: [player]")
			continue

		// Initial screening check. Does the player even have the job enabled, if they do - Is it at the correct priority level?
		var/player_job_level = player.client?.prefs.job_preferences[job.title]
		if(isnull(player_job_level))
			job_debug("FOC: Player job not enabled, Player: [player]")
			continue

		if(level && (player_job_level != level))
			job_debug("FOC: Player job enabled at wrong level, Player: [player], TheirLevel: [job_priority_level_to_string(player_job_level)], ReqLevel: [job_priority_level_to_string(level)]")
			continue

		// This check handles its own output to job_debug.
		if(check_job_eligibility(player, job, "FOC", add_job_to_log = FALSE) != JOB_AVAILABLE)
			continue

		// They have the job enabled, at this priority level, with no restrictions applying to them.
		job_debug("FOC: Player eligible, Player: [player], Level: [job_priority_level_to_string(level)]")
		candidates += player
	return candidates


/datum/controller/subsystem/job/proc/give_random_job(mob/dead/new_player/player)
	job_debug("GRJ: Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job as anything in shuffle(joinable_occupations))
		if(QDELETED(player))
			job_debug("GRJ: Player is deleted, aborting")
			break

		if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
			job_debug("GRJ: Job lacks spawn positions to be eligible, Player: [player], Job: [job]")
			continue

		if(istype(job, get_job_type(overflow_role))) // We don't want to give him assistant, that's boring!
			job_debug("GRJ: Skipping overflow role, Player: [player], Job: [job]")
			continue

		if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //If you want a command position, select it!
			job_debug("GRJ: Skipping command role, Player: [player], Job: [job]")
			continue

		// This check handles its own output to job_debug.
		if(check_job_eligibility(player, job, "GRJ", add_job_to_log = TRUE) != JOB_AVAILABLE)
			continue

		if(assign_role(player, job, do_eligibility_checks = FALSE))
			job_debug("GRJ: Random job given, Player: [player], Job: [job]")
			return TRUE

		job_debug("GRJ: Player eligible but assign_role failed, Player: [player], Job: [job]")


/datum/controller/subsystem/job/proc/reset_occupations()
	job_debug("RO: Occupations reset.")
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player?.mind)
			continue
		player.mind.set_assigned_role(get_job_type(/datum/job/unassigned))
		player.mind.special_role = null
	setup_occupations()
	unassigned = list()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		// Any errors with the configs has already been said, we don't need to repeat them here.
		load_jobs_from_config(silent = TRUE)
	set_overflow_role(overflow_role)
	return


/*
 * Forces a random Head of Staff role to be assigned to a random eligible player.
 * Returns TRUE if a player was selected and assigned the role. FALSE otherwise.
 */
/datum/controller/subsystem/job/proc/force_one_head_assignment()
	var/datum/job_department/command_department = get_department_type(/datum/job_department/command)
	if(!command_department)
		return FALSE
	for(var/level in level_order)
		for(var/datum/job/job as anything in command_department.department_jobs)
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = find_occupation_candidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			// Eligibility checks done as part of find_occupation_candidates.
			if(assign_role(candidate, job, do_eligibility_checks = FALSE))
				return TRUE
	return FALSE


/**
 * Attempts to fill out all possible head positions for players with that job at a a given job priority level.
 * Returns the number of Head positions assigned.
 *
 * Arguments:
 * * level - One of the JP_LOW, JP_MEDIUM, JP_HIGH or JP_ANY defines. Attempts to find candidates with head jobs at that priority only.
 */
/datum/controller/subsystem/job/proc/fill_all_head_positions_at_priority(level)
	. = 0
	var/datum/job_department/command_department = get_department_type(/datum/job_department/command)

	if(!command_department)
		return .

	for(var/datum/job/job as anything in command_department.department_jobs)
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue

		var/list/candidates = find_occupation_candidates(job, level)
		if(!candidates.len)
			continue

		var/mob/dead/new_player/candidate = pick(candidates)

		// Eligibility checks done as part of find_occupation_candidates() above.
		if(!assign_role(candidate, job, do_eligibility_checks = FALSE))
			continue

		.++

		if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
			job_debug("JOBS: Command Job is now full, Job: [job], Positions: [job.current_positions], Limit: [job.spawn_positions]")

/// Attempts to fill out all available AI positions.
/datum/controller/subsystem/job/proc/fill_ai_positions()
	var/datum/job/ai_job = get_job(JOB_AI)
	if(!ai_job)
		return
	// In byond for(in to) loops, the iteration is inclusive so we need to stop at ai_job.total_positions - 1
	for(var/i in ai_job.current_positions to ai_job.total_positions - 1)
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = find_occupation_candidates(ai_job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				// Eligibility checks done as part of find_occupation_candidates
				if(assign_role(candidate, get_job_type(/datum/job/ai), do_eligibility_checks = FALSE))
					break


/** Proc divide_occupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/divide_occupations(pure = FALSE, allow_all = FALSE)
	//Setup new player list and get the jobs list
	job_debug("DO: Running, allow_all = [allow_all], pure = [pure]")
	run_divide_occupation_pure = pure
	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_DIVIDED, pure, allow_all)

	//Get the players who are ready
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences() && player.mind && is_unassigned_job(player.mind.assigned_role))
			unassigned += player

	initial_players_to_assign = length(unassigned)

	job_debug("DO: Player count to assign roles to: [initial_players_to_assign]")

	//Scale number of open security officer slots to population
	setup_officer_positions()

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/min_access_threshold = CONFIG_GET(number/minimal_access_threshold)
	if(min_access_threshold)
		if(min_access_threshold > initial_players_to_assign)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle player list.
	shuffle_inplace(unassigned)

	handle_feedback_gathering()

	// Assign any priority positions before all other standard job selections.
	job_debug("DO: Assigning priority positions")
	assign_priority_positions()
	job_debug("DO: Priority assignment complete")

	// The overflow role has limitless slots, plus having the Overflow box ticked in prefs should (with one exception) set the priority to JP_HIGH.
	// So everyone with overflow enabled will get that job. Thus we can assign it immediately to all players that have it enabled.
	job_debug("DO: Assigning early overflow roles")
	assign_all_overflow_positions()
	job_debug("DO: Early overflow roles assigned.")

	// At this point we can assume the following:
	// From assign_priority_positions()
	// 1. If possible, any necessary job roles to allow Dynamic rulesets to execute (such as an AI for malf AI) are satisfied.
	// 2. All Head of Staff roles with any player pref set to JP_HIGH are filled out.
	// 3. If any player not selected by the above has any Head of Staff preference enabled at any JP_ level, there is at least one Head of Staff.
	//
	// From assign_all_overflow_positions()
	// 4. Anyone with the overflow role enabled has been given the overflow role.

	// Copy the joinable occupation list and filter out ineligible occupations due to above job assignments.
	var/list/available_occupations = joinable_occupations.Copy()
	var/datum/job_department/command_department = get_department_type(/datum/job_department/command)

	for(var/datum/job/job in available_occupations)
		// Make sure the job isn't filled. If it is, remove it from the list so it doesn't get checked.
		if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
			job_debug("DO: Job is now filled, Job: [job], Current: [job.current_positions], Limit: [job.spawn_positions]")
			available_occupations -= job
			continue

		// Command jobs are handled via fill_all_head_positions_at_priority(...)
		// Remove these jobs from the list of available occupations to prevent multiple players being assigned to the same
		// limited role without constantly having to iterate over the available_occupations list and re-check them.
		if(job in command_department?.department_jobs)
			available_occupations -= job

	job_debug("DO: Running standard job assignment")

	for(var/level in level_order)
		job_debug("JOBS: Filling in head roles, Level: [job_priority_level_to_string(level)]")
		// Fill the head jobs first each level
		fill_all_head_positions_at_priority(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)
			if(!allow_all)
				if(popcap_reached())
					job_debug("JOBS: Popcap reached, trying to reject player: [player]")
					try_reject_player(player)

			job_debug("JOBS: Finding a job for player: [player], at job priority pref: [job_priority_level_to_string(level)]")

			// Loop through all jobs and build a list of jobs this player could be eligible for.
			var/list/possible_jobs = list()
			for(var/datum/job/job in available_occupations)
				// Filter any job that doesn't fit the current level.
				var/player_job_level = player.client?.prefs.job_preferences[job.title]
				if(isnull(player_job_level))
					job_debug("JOBS: Job not enabled, Job: [job]")
					continue
				if(player_job_level != level)
					job_debug("JOBS: Job enabled at different priority pref, Job: [job], TheirLevel: [job_priority_level_to_string(player_job_level)], ReqLevel: [job_priority_level_to_string(level)]")
					continue

				if(check_job_eligibility(player, job, "JOBS", add_job_to_log = TRUE) != JOB_AVAILABLE)
					continue

				possible_jobs += job

			// If there are no possible jobs for them at this priority, skip them.
			if(!length(possible_jobs))
				job_debug("JOBS: Player not eligible for any available jobs at this priority level: [player]")
				continue

			// Otherwise, pick one of those jobs at random.
			var/datum/job/picked_job = pick(possible_jobs)

			job_debug("JOBS: Now assigning role to player: [player], Job:[picked_job.title]")
			assign_role(player, picked_job, do_eligibility_checks = FALSE)
			if((picked_job.current_positions >= picked_job.spawn_positions) && picked_job.spawn_positions != -1)
				job_debug("JOBS: Job is now full, Job: [picked_job], Positions: [picked_job.current_positions], Limit: [picked_job.spawn_positions]")
				available_occupations -= picked_job

	job_debug("DO: Ending standard job assignment")

	job_debug("DO: Handle unassigned")
	// For any players that didn't get a job, fall back on their pref setting for what to do.
	for(var/mob/dead/new_player/player in unassigned)
		handle_unassigned(player, allow_all)
	job_debug("DO: Ending handle unassigned")

	job_debug("DO: Handle unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!give_random_job(player))
			if(!assign_role(player, get_job_type(overflow_role))) //If everything is already filled, make them an assistant
				job_debug("DO: Forced antagonist could not be assigned any random job or the overflow role. divide_occupations failed.")
				job_debug("---------------------------------------------------")
				run_divide_occupation_pure = FALSE
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll
	job_debug("DO: Ending handle unrejectable unassigned")

	job_debug("All divide occupations tasks completed.")
	job_debug("---------------------------------------------------")
	run_divide_occupation_pure = FALSE
	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/handle_unassigned(mob/dead/new_player/player, allow_all = FALSE)
	var/jobless_role = player.client.prefs.read_preference(/datum/preference/choiced/jobless_role)

	if(!allow_all)
		if(popcap_reached())
			job_debug("HU: Popcap reached, trying to reject player: [player]")
			try_reject_player(player)
			return

	switch (jobless_role)
		if (BEOVERFLOW)
			var/datum/job/overflow_role_datum = get_job_type(overflow_role)

			if(check_job_eligibility(player, overflow_role_datum, debug_prefix = "HU", add_job_to_log = TRUE) != JOB_AVAILABLE)
				job_debug("HU: Player cannot be overflow, trying to reject: [player]")
				try_reject_player(player)
				return

			if(!assign_role(player, overflow_role_datum, do_eligibility_checks = FALSE))
				job_debug("HU: Player could not be assigned overflow role, trying to reject: [player]")
				try_reject_player(player)
				return
		if (BERANDOMJOB)
			if(!give_random_job(player))
				job_debug("HU: Player cannot be given a random job, trying to reject: [player]")
				try_reject_player(player)
				return
		if (RETURNTOLOBBY)
			job_debug("HU: Player unable to be assigned job, return to lobby enabled: [player]")
			try_reject_player(player)
			return
		else //Something gone wrong if we got here.
			job_debug("HU: [player] has an invalid jobless_role var: [jobless_role]")
			log_game("[player] has an invalid jobless_role var: [jobless_role]")
			message_admins("[player] has an invalid jobless_role, this shouldn't happen.")
			try_reject_player(player)


//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/equip_rank(mob/living/equipping, datum/job/job, client/player_client)
	// DOPPLER EDIT ADDITION BEGIN - ALTERNATIVE_JOB_TITLES
	// The alt job title, if user picked one, or the default
	var/alt_title = player_client?.prefs.alt_job_titles?[job.title] || job.title
	// DOPPLER EDIT ADDITION END
	equipping.job = job.title

	SEND_SIGNAL(equipping, COMSIG_JOB_RECEIVED, job)

	equipping.mind?.set_assigned_role_with_greeting(job, player_client, alt_title)
	equipping.on_job_equipping(job, player_client)
	job.announce_job(equipping, alt_title) // DOPPLER EDIT: alternative job titles

	if(player_client?.holder)
		if(CONFIG_GET(flag/auto_deadmin_players) || (player_client.prefs?.toggles & DEADMIN_ALWAYS))
			player_client.holder.auto_deadmin()
		else
			handle_auto_deadmin_roles(player_client, job.title)

	setup_alt_job_title(equipping, job, player_client) // DOPPLER ADDITION: alternative job titles
	job.after_spawn(equipping, player_client)

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = get_job(rank)

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
	var/datum/job/J = SSjob.get_job(JOB_SECURITY_OFFICER)
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	var/ssc = CONFIG_GET(number/security_scaling_coeff)
	if(ssc > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len / ssc))) //Scale between configured minimum and 12 officers
			job_debug("SOP: Setting open security officer positions to [officer_positions]")
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

/datum/controller/subsystem/job/proc/handle_feedback_gathering()
	for(var/datum/job/job as anything in joinable_occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		var/newbie = 0 //exp too low
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
				newbie++
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
		SSblackbox.record_feedback("nested tally", "job_preferences", newbie, list("[job.title]", "newbie"))

/datum/controller/subsystem/job/proc/popcap_reached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/try_reject_player(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		job_debug("RJCT: Player unable to be rejected due to special_role, Player: [player], SpecialRole: [player.mind.special_role]")
		return FALSE

	job_debug("RJCT: Player rejected, Player: [player]")
	unassigned -= player
	if(!run_divide_occupation_pure)
		to_chat(player, span_infoplain("<b>You have failed to qualify for any job you desired.</b>"))
		player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.all_occupations
	sleep(2 SECONDS)
	for (var/datum/job/job as anything in oldjobs)
		INVOKE_ASYNC(src, PROC_REF(recover_job), job)

/datum/controller/subsystem/job/proc/recover_job(datum/job/J)
	var/datum/job/newjob = get_job(J.title)
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

/datum/controller/subsystem/job/proc/send_to_late_join(mob/M, buckle = TRUE)
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
	var/area/shuttle/arrival/arrivals_area = GLOB.areas_by_type[/area/shuttle/arrival]
	if(!isnull(arrivals_area))
		var/list/turf/available_turfs = list()
		for (var/list/zlevel_turfs as anything in arrivals_area.get_zlevel_turf_lists())
			for (var/turf/arrivals_turf as anything in zlevel_turfs)
				var/obj/structure/chair/shuttle_chair = locate() in arrivals_turf
				if(!isnull(shuttle_chair))
					return shuttle_chair
				if(arrivals_turf.is_blocked_turf(TRUE))
					continue
				available_turfs += arrivals_turf

		if(length(available_turfs))
			return pick(available_turfs)

	stack_trace("Unable to find last resort spawn point.")
	return GET_ERROR_ROOM

/// Returns a list of minds of all heads of staff who are alive
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/datum/mind/head as anything in get_crewmember_minds())
		if(!(head.assigned_role.job_flags & JOB_HEAD_OF_STAFF))
			continue
		if(isnull(head.current) || head.current.stat == DEAD)
			continue
		. += head

/// Returns a list of minds of all heads of staff
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/datum/mind/head as anything in get_crewmember_minds())
		if(head.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			. += head

/// Returns a list of minds of all security members who are alive
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/datum/mind/sec as anything in get_crewmember_minds())
		if(!(sec.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			continue
		if(isnull(sec.current) || sec.current.stat == DEAD)
			continue
		. += sec

/// Returns a list of minds of all security members
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/datum/mind/sec as anything in get_crewmember_minds())
		if(sec.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			. += sec

/datum/controller/subsystem/job/proc/job_debug(message)
	log_job_debug(message)

/// Builds various lists of jobs based on station, centcom and additional jobs with icons associated with them.
/datum/controller/subsystem/job/proc/setup_job_lists()
	job_priorities_to_strings = list(
		"[JP_LOW]" = "Low Priority",
		"[JP_MEDIUM]" = "Medium Priority",
		"[JP_HIGH]" = "High Priority",
	)

/obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code
	name = "Nanotrasen-Approved Spare ID Safe Code"
	desc = "Proof that you have been approved for Captaincy, with all its glory and all its horror."

/obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code/Initialize(mapload)
	var/safe_code = SSid_access.spare_id_safe_code
	default_raw_text = "Captain's Spare ID safe code combination: [safe_code ? safe_code : "\[REDACTED\]"]<br><br>The spare ID can be found in its dedicated safe on the bridge.<br><br>If your job would not ordinarily have Head of Staff access, your ID card has been specially modified to possess it."
	return ..()

/obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code
	name = "Emergency Spare ID Safe Code Requisition"
	desc = "Proof that nobody has been approved for Captaincy. A skeleton key for a skeleton shift."

/obj/item/paper/paperslip/corporate/fluff/emergency_spare_id_safe_code/Initialize(mapload)
	var/safe_code = SSid_access.spare_id_safe_code
	default_raw_text = "Captain's Spare ID safe code combination: [safe_code ? safe_code : "\[REDACTED\]"]<br><br>The spare ID can be found in its dedicated safe on the bridge."
	return ..()

/datum/controller/subsystem/job/proc/promote_to_captain(mob/living/carbon/human/new_captain, acting_captain = FALSE)
	var/id_safe_code = SSid_access.spare_id_safe_code

	if(!id_safe_code)
		CRASH("Cannot promote [new_captain.real_name] to Captain, there is no id_safe_code.")

	var/paper = new /obj/item/folder/biscuit/confidential/spare_id_safe_code()
	var/list/slots = list(
		LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
		LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS
	)
	var/where = new_captain.equip_in_one_of_slots(paper, slots, FALSE, indirect_action = TRUE) || "at your feet"

	if(acting_captain)
		to_chat(new_captain, span_notice("Due to your position in the chain of command, you have been promoted to Acting Captain. You can find in important note about this [where]."))
	else
		to_chat(new_captain, span_notice("You can find the code to obtain your spare ID from the secure safe on the Bridge [where]."))
		new_captain.add_mob_memory(/datum/memory/key/captains_spare_code, safe_code = SSid_access.spare_id_safe_code)

	// Force-give their ID card bridge access.
	var/obj/item/id_slot = new_captain.get_item_by_slot(ITEM_SLOT_ID)
	if(id_slot)
		var/obj/item/card/id/id_card = id_slot.GetID()
		if(!(ACCESS_COMMAND in id_card.access))
			id_card.add_wildcards(list(ACCESS_COMMAND), mode=FORCE_ADD_ALL)

	assigned_captain = TRUE

/// Send a drop pod containing a piece of paper with the spare ID safe code to loc
/datum/controller/subsystem/job/proc/send_spare_id_safe_code(loc)
	new /obj/effect/pod_landingzone(loc, /obj/structure/closet/supplypod/centcompod, new /obj/item/folder/biscuit/confidential/emergency_spare_id_safe_code())
	safe_code_timer_id = null
	safe_code_request_loc = null

/// Assigns roles that are considered high priority, either due to dynamic needing to force a specific role for a specific ruleset
/// or making sure roles critical to round progression exist where possible every shift.
/datum/controller/subsystem/job/proc/assign_priority_positions()
	job_debug("APP: Assigning Dynamic ruleset forced occupations: [length(dynamic_forced_occupations)]")
	for(var/mob/new_player in dynamic_forced_occupations)
		// Eligibility checks already carried out as part of the dynamic ruleset trim_candidates proc.
		// However no guarantee of game state between then and now, so don't skip eligibility checks on assign_role.
		assign_role(new_player, get_job(dynamic_forced_occupations[new_player]))

	// Get JP_HIGH department Heads of Staff in place. Indirectly useful for the Revolution ruleset to have as many Heads as possible.
	job_debug("APP: Assigning all JP_HIGH head of staff roles.")
	var/head_count = fill_all_head_positions_at_priority(JP_HIGH)

	// If nobody has JP_HIGH on a Head role, try to force at least one Head of Staff so every shift has the best chance
	// of having at least one leadership role.
	if(head_count == 0)
		force_one_head_assignment()

	// Fill out all AI positions.
	job_debug("APP: Filling all AI positions")
	fill_ai_positions()

/datum/controller/subsystem/job/proc/assign_all_overflow_positions()
	job_debug("OVRFLW: Assigning all overflow roles.")
	job_debug("OVRFLW: This shift's overflow role: [overflow_role]")
	var/datum/job/overflow_datum = get_job_type(overflow_role)

	// When the Overflow role changes for any reason, this allows players to set otherwise invalid job priority pref states.
	// So if Assistant is the "usual" Overflow but it gets changed to Clown for a shift, players can set the Assistant role's priorities
	// to JP_MEDIUM and JP_LOW. When the "usual" Overflow role comes back, it returns to an On option in the prefs menu but still
	// keeps its old JP_MEDIUM or JP_LOW value in the background.

	// Due to this prefs quirk, we actually don't want to find JP_HIGH candidates as it may exclude people with abnormal pref states that
	// appear normal from the UI. By passing in JP_ANY, it will return all players that have the overflow job pref (which should be a toggle)
	// set to any level.
	var/list/overflow_candidates = find_occupation_candidates(overflow_datum, JP_ANY)
	for(var/mob/dead/new_player/player in overflow_candidates)
		// Eligibility checks done as part of find_occupation_candidates, so skip them.
		assign_role(player, get_job_type(overflow_role), do_eligibility_checks = FALSE)
		job_debug("OVRFLW: Assigned overflow to player: [player]")
	job_debug("OVRFLW: All overflow roles assigned.")

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
 * * debug_prefix - Logging prefix for the job_debug log entries. For example, GRJ during give_random_job or DO during divide_occupations.
 * * add_job_to_log - If TRUE, appends the job type to the log entry. If FALSE, does not. Set to FALSE when check is part of iterating over players for a specific job, set to TRUE when check is part of iterating over jobs for a specific player and you don't want extra log entry spam.
 */
/datum/controller/subsystem/job/proc/check_job_eligibility(mob/dead/new_player/player, datum/job/possible_job, debug_prefix = "", add_job_to_log = FALSE)
	if(!player.mind)
		job_debug("[debug_prefix]: Player has no mind, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	if(possible_job.title in player.mind.restricted_roles)
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ANTAG_INCOMPAT, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ANTAG_INCOMPAT

	if(!possible_job.player_old_enough(player.client))
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ACCOUNTAGE, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ACCOUNTAGE

	var/required_playtime_remaining = possible_job.required_playtime_remaining(player.client)
	if(required_playtime_remaining)
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_PLAYTIME, possible_job.title)], Player: [player], MissingTime: [required_playtime_remaining][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_PLAYTIME

	// Run the banned check last since it should be the rarest check to fail and can access the database.
	if(is_banned_from(player.ckey, possible_job.title))
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_BANNED, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_BANNED

	// Check for character age
	if(possible_job.required_character_age > player.client.prefs.read_preference(/datum/preference/numeric/age) && possible_job.required_character_age != null)
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_AGE)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_AGE

	// Need to recheck the player exists after is_banned_from since it can query the DB which may sleep.
	if(QDELETED(player))
		job_debug("[debug_prefix]: Player is qdeleted, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	return JOB_AVAILABLE

/**
 * Check if the station manifest has at least a certain amount of this staff type.
 * If a matching head of staff is on the manifest, automatically passes (returns TRUE)
 *
 * Arguments:
 * * crew_threshold - amount of crew to meet the requirement
 * * jobs - a list of jobs that qualify the requirement
 * * head_jobs - a list of head jobs that qualify the requirement
 *
*/
/datum/controller/subsystem/job/proc/has_minimum_jobs(crew_threshold, list/jobs = list(), list/head_jobs = list())
	var/employees = 0
	for(var/datum/record/crew/target in GLOB.manifest.general)
		if(target.trim in head_jobs)
			return TRUE
		if(target.trim in jobs)
			employees++

	if(employees > crew_threshold)
		return TRUE

	return FALSE
