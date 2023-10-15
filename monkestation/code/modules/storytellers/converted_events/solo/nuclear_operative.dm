/datum/round_event_control/antagonist/solo/nuclear_operative
	name = "Roundstart Nuclear Operative"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	typepath = /datum/round_event/antagonist/solo/nuclear_operative
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	base_antags = 3
	maximum_antags = 5
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_enemies = 5
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event/antagonist/solo/nuclear_operative
	excute_round_end_reports = TRUE
	end_when = 60000 /// we will end on our own when revs win
	var/static/datum/team/nuclear/nuke_team
	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	var/set_leader = FALSE

/datum/round_event/antagonist/solo/nuclear_operative/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/mind/most_experienced = get_most_experienced(assigned, required_role)
	if(!most_experienced)
		most_experienced = antag_mind

	if(!set_leader)
		set_leader = TRUE
		var/datum/antagonist/nukeop/leader/leader = most_experienced.add_antag_datum(antag_leader_datum)
		nuke_team = leader.nuke_team

	if(antag_mind == most_experienced)
		return

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)


/datum/round_event/antagonist/solo/revolutionary/round_end_report()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH
