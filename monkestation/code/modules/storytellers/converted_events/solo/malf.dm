/datum/round_event_control/antagonist/solo/malf
	antag_datum = /datum/antagonist/malf_ai
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_ALIEN) //not exactly alien but close enough
	antag_flag = ROLE_MALF
	enemy_roles = list(
		JOB_CHEMIST,
		JOB_CHIEF_ENGINEER,
		JOB_HEAD_OF_SECURITY,
		JOB_RESEARCH_DIRECTOR,
		JOB_SCIENTIST,
		JOB_ROBOTICIST,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	shared_occurence_type = SHARED_HIGH_THREAT
	maximum_antags = 1
	exclusive_roles = list(JOB_AI)
	required_enemies = 4
	weight = 6
	min_players = 35
	max_occurrences = 1

/datum/round_event_control/antagonist/solo/malf/trim_candidates(list/candidates)
	for(var/mob/living/player in candidates)
		if(!isAI(player))
			candidates -= player
			continue

		if(is_centcom_level(player.z))
			candidates -= player
			continue

		if(player.mind && (player.mind.special_role || player.mind.antag_datums?.len > 0))
			candidates -= player

	return candidates

/datum/round_event_control/antagonist/solo/malf/midround
	name = "Malfunctioning AI Midround"
	antag_flag = ROLE_MALF_MIDROUND
	weight = 2

/datum/round_event_control/antagonist/solo/malf/roundstart
	name = "Roundstart Malf AI"
	roundstart = TRUE
	earliest_start = 0
