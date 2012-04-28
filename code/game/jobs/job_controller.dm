var/global/datum/controller/occupations/job_master

/datum/controller/occupations
	var
		//List of all jobs
		list/occupations = list()
		list/occupations2 = list() // Prevents problems with latejoiners.
		//Players who need jobs
		list/unassigned = list()
		//Debug info
		list/job_debug = list()


	New()
		spawn(1)
			SetupOccupations()
		return


	proc/SetupOccupations(var/faction = "Station")
		occupations = list()
		var/list/all_jobs = typesof(/datum/job)
		if(!all_jobs.len)
			world << "\red \b Error setting up jobs, no job datums found"
			return 0
		for(var/J in all_jobs)
			var/datum/job/job = new J()
			if(!job)	continue
			if(job.faction != faction)	continue
			occupations += job


		return 1


	proc/Debug(var/text)
		if(!Debug2)	return 0
		job_debug.Add(text)
		return 1


	proc/GetJob(var/rank)
		if(!rank)	return null
		for(var/datum/job/J in occupations)
			if(!J)	continue
			if(J.title == rank)	return J
		return null


	proc/GetAltTitle(mob/new_player/player, rank)
		return player.preferences.GetAltTitle(GetJob(rank))


	proc/AssignRole(var/mob/new_player/player, var/rank, var/latejoin = 0)
		Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
		if((player) && (player.mind) && (rank))
			var/datum/job/job = GetJob(rank)
			if(!job)	return 0
			if(jobban_isbanned(player, rank))	return 0
			var/position_limit = job.total_positions
			if(!latejoin)
				position_limit = job.spawn_positions
			if((job.current_positions < position_limit) || position_limit == -1)
				Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
				player.mind.assigned_role = rank
				player.mind.role_alt_title = GetAltTitle(player, rank)
				unassigned -= player
				job.current_positions++
				return 1
		Debug("AR has failed, Player: [player], Rank: [rank]")
		return 0


	proc/FindOccupationCandidates(datum/job/job, level, flag)
		Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
		var/list/candidates = list()
		for(var/mob/new_player/player in unassigned)
			if(jobban_isbanned(player, job.title))
				Debug("FOC isbanned failed, Player: [player]")
				continue
			if(flag && (!player.preferences.be_special & flag))
				Debug("FOC flag failed, Player: [player], Flag: [flag], ")
				continue
			if(player.preferences.GetJobDepartment(job, level) & job.flag)
				Debug("FOC pass, Player: [player], Level:[level]")
				candidates += player
		return candidates


	proc/ResetOccupations()
		for(var/mob/new_player/player in world)
			if((player) && (player.mind))
				player.mind.assigned_role = null
				player.mind.role_alt_title = null
				player.mind.special_role = null
		SetupOccupations()
		unassigned = list()
		return


	proc/FillHeadPosition()
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


	proc/FillAIPosition()
		// this now only forces AI if malf mode
		if(ticker.mode.name != "AI malfunction")
			return

		var/ai_selected = 0
		var/datum/job/job = GetJob("AI")
		if(!job)	return 0
		if((job.title == "AI") && (config) && (!config.allow_ai))	return 0

		for(var/level = 1 to 3)
			var/list/candidates = list()
			if(ticker.mode.name == "AI malfunction")//Make sure they want to malf if its malf
				candidates = FindOccupationCandidates(job, level, BE_MALF)
			else
				candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
		//Malf NEEDS an AI so force one if we didn't get a player who wanted it
		if((ticker.mode.name == "AI malfunction")&&(!ai_selected))
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))	continue
				if(AssignRole(player, "AI"))
					ai_selected++
					break
		if(ai_selected)	return 1
		return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
	proc/DivideOccupations()
		//Setup new player list and get the jobs list
		Debug("Running DO")
		SetupOccupations()

		//Get the players who are ready
		for(var/mob/new_player/player in world)
			if((player) && (player.client) && (player.ready) && (player.mind) && (!player.mind.assigned_role))
				unassigned += player

		Debug("DO, Len: [unassigned.len]")
		if(unassigned.len == 0)	return 0
		//Shuffle players and jobs
		unassigned = shuffle(unassigned)
		occupations2 = shuffle(occupations)

		//HandleFeedbackGathering()

		//Assistants are checked first
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

		//Check for an AI, now purely just for malf mode
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

		//Other jobs are now checked
		Debug("DO, Running Standard Check")
		for(var/level = 1 to 3)
			for(var/datum/job/job in occupations2)
				Debug("Checking job: [job]")
				if(!job)
					continue
				if(!unassigned.len)
					break
				if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
					continue
				var/list/candidates = FindOccupationCandidates(job, level)
				while(candidates.len && ((job.current_positions < job.spawn_positions) || job.spawn_positions == -1))
					var/mob/new_player/candidate = pick(candidates)
					Debug("Selcted: [candidate], for: [job.title]")
					AssignRole(candidate, job.title)
					candidates -= candidate
		Debug("DO, Standard Check end")

		Debug("DO, Running AC2")
		for(var/mob/new_player/player in unassigned)
			Debug("AC2 Assistant located, Player: [player]")
			AssignRole(player, "Assistant")
		return 1


	proc/EquipRank(var/mob/living/carbon/human/H, var/rank, var/joined_late = 0)
		if(!H)	return 0
		var/datum/job/job = GetJob(rank)
		if(job)
			job.equip(H)
		else
			H << "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

		if(H.mind.assigned_role == rank && H.mind.role_alt_title)
			spawnId(H, rank, H.mind.role_alt_title)
		else
			spawnId(H, rank)
		H << "<B>You are the [rank].</B>"
		H << "<b>As the [rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>"
		H.job = rank
		if(H.mind && H.mind.assigned_role != rank)
			H.mind.assigned_role = rank
			H.mind.role_alt_title = null

		if(!joined_late)
			var/obj/S = null
			for(var/obj/effect/landmark/start/sloc in world)
				if(sloc.name != rank)	continue
				if(locate(/mob/living) in sloc.loc)	continue
				S = sloc
				break
			if(!S)
				S = locate("start*[rank]") // use old stype
			if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				H.loc = S.loc

		if(H.mind && H.mind.assigned_role == "Cyborg")//This could likely be done somewhere else
			H.Robotize()
			return 1

		// make sure we don't already have one on 1 ear :p
		if(!istype(H.r_ear,/obj/item/device/radio/headset) && !istype(H.l_ear,/obj/item/device/radio/headset))
			H.equip_if_possible(new /obj/item/device/radio/headset(H), H.slot_ears)

		if(H.mind && H.mind.assigned_role != "Cyborg" && H.mind.assigned_role != "AI" && H.mind.assigned_role != "Clown")
			if(H.backbag == 1) //Clown always gets his backbuddy.
				H.equip_if_possible(new /obj/item/weapon/storage/box(H), H.slot_r_hand)

			if(H.backbag == 2)
				var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(H)
				new /obj/item/weapon/storage/box(BPK)
				H.equip_if_possible(BPK, H.slot_back,1)

			if(H.backbag == 3)
				var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel(H)
				new /obj/item/weapon/storage/box(BPK)
				H.equip_if_possible(BPK, H.slot_back,1)

			if(H.backbag == 4)
				var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel_norm(H)
				new /obj/item/weapon/storage/box(BPK)
				H.equip_if_possible(BPK, H.slot_back,1)

		//Give'em glasses if they are nearsighted
		if(H.disabilities & 1)
			var/equipped = H.equip_if_possible(new /obj/item/clothing/glasses/regular(H), H.slot_glasses)
			if(!equipped)
				var/obj/item/clothing/glasses/G = H.glasses
				G.prescription = 1
		H.update_clothing()
		return 1


	proc/spawnId(var/mob/living/carbon/human/H, rank, title)
		if(!H)	return 0
		if(!title) title = rank
		var/obj/item/weapon/card/id/C = null
		switch(rank)
			if("Cyborg")
				return
			if("Captain")
				C = new /obj/item/weapon/card/id/gold(H)
			else
				C = new /obj/item/weapon/card/id(H)
		if(C)
			C.registered_name = H.real_name
			C.assignment = title
			C.name = "[C.registered_name]'s ID Card ([C.assignment])"
			C.access = get_access(rank)
			H.equip_if_possible(C, H.slot_wear_id)
		if(!H.equip_if_possible(new /obj/item/weapon/pen(H), H.slot_r_store))
			H.equip_if_possible(new /obj/item/weapon/pen(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/device/pda(H), H.slot_belt)
		if(locate(/obj/item/device/pda,H))//I bet this could just use locate.  It can --SkyMarshal
			var/obj/item/device/pda/pda = locate(/obj/item/device/pda,H)
			pda.owner = H.real_name
			pda.ownjob = H.wear_id.assignment
			pda.name = "PDA-[H.real_name] ([pda.ownjob])"

		/*if(rank == "Clown")
			spawn(1)
				clname(H)*/
		return 1


	proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
		if(!config.load_jobs_from_txt)
			return 0

		var/text = file2text(jobsfile)

		if(!text)
			world << "No jobs.txt found, using defaults."
			return

		var/list/jobEntries = dd_text2list(text, "\n")

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

/*
	proc/HandleFeedbackGathering()
		for(var/datum/job/job in occupations)
			var/tmp_str = "|[job.title]|"

			var/level1 = 0 //high
			var/level2 = 0 //medium
			var/level3 = 0 //low
			var/level4 = 0 //never
			var/level5 = 0 //banned
			for(var/mob/new_player/player in world)
				if(!((player) && (player.client) && (player.ready) && (player.mind) && (!player.mind.assigned_role)))
					continue //This player is not ready
				if(jobban_isbanned(player, job.title))
					level5++
					continue
				if(player.preferences.GetJobDepartment(job, 1) & job.flag)
					level1++
				else if(player.preferences.GetJobDepartment(job, 2) & job.flag)
					level2++
				else if(player.preferences.GetJobDepartment(job, 3) & job.flag)
					level3++
				else level4++ //not selected

			tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|-"
			feedback_add_details("job_preferences",tmp_str)
*/