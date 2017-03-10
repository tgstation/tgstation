/datum/round_event_control/inspector
	name = "Inspector"
	typepath = /datum/round_event/ghost_role/inspector
	weight = 0

/datum/round_event/ghost_role/inspector
	minimum_required = 1
	role_name = "Centcom Official"
	var/mission

/datum/round_event/ghost_role/inspector/setup()
	mission = "Conduct a routine preformance review of [station_name()] and its Captain."

/datum/round_event/ghost_role/inspector/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates("deathsquad")

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/chosen_candidate = pick(candidates)

	//Create the official
	var/turf/T = pick(emergencyresponseteamspawn)
	if(!T)
		return MAP_ERROR

	var/mob/living/carbon/human/newmob = new(T)

	chosen_candidate.client.prefs.copy_to(newmob)
	newmob.real_name = newmob.dna.species.random_name(newmob.gender,1)
	newmob.dna.update_dna_identity()
	newmob.key = chosen_candidate.key
	newmob.mind.assigned_role = "Centcom Official"
	newmob.equipOutfit(/datum/outfit/centcom_official)

	//Assign antag status and the mission
	ticker.mode.traitors += newmob.mind
	newmob.mind.special_role = "official"
	var/datum/objective/missionobj = new
	missionobj.owner = newmob.mind
	missionobj.explanation_text = mission
	missionobj.completed = 1
	newmob.mind.objectives += missionobj

	if(config.enforce_human_authority)
		newmob.set_species(/datum/species/human)

	//Greet the official
	newmob << "<B><font size=3 color=red>You are a Centcom Official.</font></B>"
	newmob << "<BR>Central Command is sending you to [station_name()] with the task: [mission]"

	//Logging and cleanup
	message_admins("Centcom Official [key_name_admin(newmob)] has spawned with the task: [mission]")
	log_game("[key_name(newmob)] has been selected as a Centcom Official")
	return SUCCESSFUL_SPAWN
