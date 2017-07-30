/datum/admins/proc/makeJesus()

	var/objective = "Perform miracles to save the crew from the sin that rages aboard this station!"
	var/list/candidates = pollGhostCandidates("Do you wish to be considered to return as a Messiah?")
	if(candidates.len)
		var/mob/dead/observer/chosen_candidate = pick(candidates)
		var/turf/spawnloc = PrepareJesusSpawns()
		if(!spawnloc || !chosen_candidate.key)
			return 0
		var/mob/living/carbon/human/Jesus = new(spawnloc)
		Jesus.unascend_animation()
		chosen_candidate.client.prefs.copy_to(Jesus)
		Jesus.key = chosen_candidate.key
		Jesus.dna.update_dna_identity()
		Jesus.gender = MALE
		Jesus.real_name = SSreligion.deity ? "[SSreligion.deity]" : "Space Jesus"
		Jesus.equipOutfit(/datum/outfit/jesus)
		SSticker.mode.traitors += Jesus.mind
		Jesus.mind.special_role = "jesus"
		Jesus.mind.assigned_role = "Jesus"
		var/datum/objective/missionobj = new
		missionobj.owner = Jesus.mind
		missionobj.explanation_text = objective
		missionobj.completed = 1
		Jesus.mind.objectives += missionobj

		to_chat(Jesus, "<B><font size=3 color=red>You are the Messiah, [Jesus.real_name]!</font></B>")
		to_chat(Jesus, "You have many miracles at your disposal. These may either be used to aid the crew or protect yourself from harm:")
		to_chat(Jesus, "<B>Ressurection: </B>After a short channeling period, this miracle brings a target back from the dead.")
		to_chat(Jesus, "<B>Blood To Wine: </B>This miracle turns blood into wine, leaving anybody nearby extremely intoxicated and unable to fight for a few minutes.")
		to_chat(Jesus, "<B>Parting Waves: </B>Once used to split the very ocean in two, this miracle is now relegated to opening airlocks. Extremely useful.")
		to_chat(Jesus, "<B>Ascend: </B>Rise up to the Heavens, and then back down to a safer area.")
		to_chat(Jesus, "<B>Repent For Your Sins: </B>After channeling for two minutes, this miracle will show any sinner the righteous path, removing their antagonist status.")
		message_admins("[key_name(Jesus)] has been selected as Jesus.")
		log_game("[key_name(Jesus)] has been selected as Jesus")
		return TRUE
	else
		return FALSE

var/list/global/JesusSpawnLocations = list()

/proc/PrepareJesusSpawns()
	if(!JesusSpawnLocations.len)
		for(var/X in GLOB.landmarks_list)
			var/obj/effect/landmark/L = X
			var/area/A = get_area(L)
			if(istype(A, /area/maintenance))
				JesusSpawnLocations += L
	var/turf/spawnloc = get_turf(pick(JesusSpawnLocations))
	return spawnloc
