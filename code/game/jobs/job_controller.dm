var/global/datum/controller/occupations/job_master

/datum/controller/occupations
		//List of all jobs
	var/list/occupations = list()
		//Players who need jobs
	var/list/unassigned = list()
		//Debug info
	var/list/job_debug = list()


/datum/controller/occupations/proc/SetupOccupations(var/faction = "Station")
	occupations = list()
	var/list/all_jobs = typesof(/datum/job)
	if(!all_jobs.len)
		world << "<span class='userdanger'>Error setting up jobs, no job datums found</span>"
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)	continue
		if(job.faction != faction)	continue
		if(!job.config_check()) continue
		occupations += job

	return 1


/datum/controller/occupations/proc/Debug(var/text)
	if(!Debug2)	return 0
	job_debug.Add(text)
	return 1


/datum/controller/occupations/proc/GetJob(var/rank)
	if(!rank)	return null
	for(var/datum/job/J in occupations)
		if(!J)	continue
		if(J.title == rank)	return J
	return null

/datum/controller/occupations/proc/AssignRole(var/mob/new_player/player, var/rank, var/latejoin = 0)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)	return 0
		if(jobban_isbanned(player, rank))	return 0
		if(!job.player_old_enough(player.client)) return 0
		if(player.mind.special_role && ticker && ticker.mode && (job.title in ticker.mode.restricted_jobs))
			return 0

		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		if((job.current_positions < position_limit) || position_limit == -1)
			Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
			player.mind.assigned_role = rank
			unassigned -= player
			job.current_positions++
			return 1
	Debug("AR has failed, Player: [player], Rank: [rank]")
	return 0


/datum/controller/occupations/proc/FindOccupationCandidates(datum/job/job, level, flag)
	Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			Debug("FOC player not old enough, Player: [player]")
			continue
		if(flag && (!player.client.prefs.be_special & flag))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue

		if(config.enforce_human_authority && (job.title in command_positions) && player.client.prefs.pref_species.id != "human")
			Debug("FOC non-human failed, Player: [player]")
			continue
		
if(player.mind.special_role && ticker && ticker.mode && (job.title in ticker.mode.restricted_jobs))
			Debug("FOC player has a special role and this job is blocked from this special role")
			continue

		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			Debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/occupations/proc/GiveRandomJob(var/mob/new_player/player)
	Debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob("Assistant"))) // We don't want to give him assistant, that's boring!
			continue

		if(job in command_positions) //If you want a command position, select it!
			continue

		if(jobban_isbanned(player, job.title))
			Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			Debug("GRJ player not old enough, Player: [player]")
			continue

		if(config.enforce_human_authority && (job.title in command_positions) && player.client.prefs.pref_species.id != "human")
			Debug("GRJ non-human failed, Player: [player]")
			continue

		if(player.mind.special_role && ticker && ticker.mode && (job.title in ticker.mode.restricted_jobs))
			Debug("GRJ player has a special role and this job is blocked from this special role")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			Debug("GRJ Random job given, Player: [player], Job: [job]")
			AssignRole(player, job.title)
			unassigned -= player
			break

/datum/controller/occupations/proc/ResetOccupations()
	for(var/mob/new_player/player in player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until�
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/occupations/proc/FillHeadPosition()
	for(var/level = 1 to 3)
		for(var/command_position in command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)	continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)	continue
			var/mob/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, command_position))
				return 1
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/occupations/proc/CheckHeadPositions(var/level)
	for(var/command_position in command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)	continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)	continue
		var/mob/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)
	return


/datum/controller/occupations/proc/FillAIPosition()
	var/ai_selected = 0
	var/datum/job/job = GetJob("AI")
	if(!job)	return 0
	if(ticker.mode.name == "AI malfunction")	// malf. AIs are pre-selected before jobs
		for (var/datum/mind/mAI in ticker.mode.malf_ai)
			AssignRole(mAI.current, "AI")
			ai_selected++
		if(ai_selected)	return 1
		return 0

	for(var/i = job.total_positions, i > 0, i--)
		for(var/level = 1 to 3)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
	if(ai_selected)	return 1
	return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/occupations/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	Debug("Running DO")
	SetupOccupations()

	//Holder for Triumvirate is stored in the ticker, this just processes it
	if(ticker)
		for(var/datum/job/ai/A in occupations)
			if(ticker.triai)
				A.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	Debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)	return 0

	//Scale number of open security officer slots to population
	setup_officer_positions()

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//People who wants to be assistants, sure, go on.
	Debug("DO, Running Assistant Check 1")
	var/datum/job/assist = new /datum/job/assistant()
	var/list/assistant_candidates = FindOccupationCandidates(assist, 3)
	Debug("AC1, Candidates: [assistant_candidates.len]")
	for(var/mob/new_player/player in assistant_candidates)
		Debug("AC1 pass, Player: [player]")
		AssignRole(player, "Assistant")
		assistant_candidates -= player
	Debug("DO, AC1 end")

	//Select one head
	Debug("DO, Running Head Check")
	FillHeadPosition()
	Debug("DO, Head Check end")

	//Check for an AI
	Debug("DO, Running AI Check")
	FillAIPosition()
	Debug("DO, AI Check end")

	//Other jobs are now checked
	Debug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					Debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				if(config.enforce_human_authority && (job.title in command_positions) && player.client.prefs.pref_species.id != "human")
					Debug("DO non-human failed, Player: [player], Job:[job.title]")
					continue

				if(player.mind.special_role && ticker && ticker.mode && (job.title in ticker.mode.restricted_jobs))
					Debug("DO player has a special role and this job is blocked from that special role")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)

					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.userandomjob)
			GiveRandomJob(player)

	Debug("DO, Standard Check end")

	Debug("DO, Running AC2")

	// For those who wanted to be assistant if their preferences were filled, here you go.
	for(var/mob/new_player/player in unassigned)
		Debug("AC2 Assistant located, Player: [player]")
		AssignRole(player, "Assistant")
	return 1

//Gives the player the stuff he should have with his rank
/datum/controller/occupations/proc/EquipRank(var/mob/living/H, var/rank, var/joined_late = 0)
	var/datum/job/job = GetJob(rank)

	H.job = rank

	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late)
		var/obj/S = null
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if(sloc.name != rank)	continue
			if(locate(/mob/living) in sloc.loc)	continue
			S = sloc
			break
		if(!S)
			S = locate("start*[rank]") // use old stype
		if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
			H.loc = S.loc

	if(H.mind)
		H.mind.assigned_role = rank

	if(job)
		var/new_mob = job.equip(H)
		if(ismob(new_mob))
			H = new_mob
		job.apply_fingerprints(H)

	H << "<b>You are the [rank].</b>"
	H << "<b>As the [rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>"
	H << "<b>To speak on your departments radio, use the :h button. To see others, look closely at your headset.</b>"
	if(job.req_admin_notify)
		H << "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>"

	H.update_hud() 	// Tmp fix for Github issue 1006. TODO: make all procs in update_icons.dm do client.screen |= equipment no matter what.
	return 1


/datum/controller/occupations/proc/setup_officer_positions()
	var/officer_positions = 5 //Number of open security officer positions at round start

	if(config.security_scaling_coeff > 0)
		officer_positions = min(12, max(5, round(unassigned.len/config.security_scaling_coeff))) //Scale between 5 and 12 officers
		var/datum/job/J = job_master.GetJob("Security Officer")
		if(J  || J.spawn_positions > 0)
			Debug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions
	for(var/i=officer_positions-5, i>0, i--) //Spawn some extra eqipment lockers if we have more than 5 officers
		if(secequipment.len)
			var/spawnloc = secequipment[1]
			new /obj/structure/closet/secure_closet/security(spawnloc)
			secequipment -= spawnloc
		else //We ran out of spare locker spawns!
			break

/datum/controller/occupations/proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
	if(!config.load_jobs_from_txt)
		return 0

	var/list/jobEntries = file2list(jobsfile)

	for(var/job in jobEntries)
		if(!job)
			continue

		job = trim(job)
		if (!length(job))
			continue

		var/pos = findtext(job, "=")
		var/name = null
		var/value = null

		if(pos)
			name = copytext(job, 1, pos)
			value = copytext(job, pos + 1)
		else
			continue

		if(name && value)
			var/datum/job/J = GetJob(name)
			if(!J)	continue
			J.total_positions = text2num(value)
			J.spawn_positions = text2num(value)
			if(name == "AI" || name == "Cyborg")//I dont like this here but it will do for now
				J.total_positions = 0

	return 1


/datum/controller/occupations/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/tmp_str = "|[job.title]|"

		var/level1 = 0 //high
		var/level2 = 0 //medium
		var/level3 = 0 //low
		var/level4 = 0 //never
		var/level5 = 0 //banned
		var/level6 = 0 //account too young
		for(var/mob/new_player/player in player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				level5++
				continue
			if(!job.player_old_enough(player.client))
				level6++
				continue
			if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
				level1++
			else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
				level2++
			else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
				level3++
			else level4++ //not selected

		tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
		feedback_add_details("job_preferences",tmp_str)
