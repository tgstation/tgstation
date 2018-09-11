/datum/admins/proc/makeInfiltratorTeam()
	var/datum/game_mode/infiltration/temp = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for a infiltration team being sent in?", ROLE_INFILTRATOR, temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle_inplace(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 infiltrators, because less than that is kinda bad
		if(agentcount < 3)
			return FALSE

		//Let's find the spawn locations
		var/datum/team/infiltrator/TI = new /datum/team/infiltrator
		for(var/mob/c in chosen)
			var/mob/living/carbon/human/new_character=makeBody(c)
			new_character.mind.add_antag_datum(/datum/antagonist/infiltrator, TI)
		return TRUE
	else
		return FALSE