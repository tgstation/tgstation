/datum/round_event_control/antagonist/solo/clown_operative
	name = "Roundstart Clown Operative"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_CLOWN_OPERATIVE
	antag_datum = /datum/antagonist/nukeop/clownop
	typepath = /datum/round_event/antagonist/solo/clown_operative
	shared_occurence_type = SHARED_HIGH_THREAT
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
		JOB_BRIG_PHYSICIAN,
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
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	required_enemies = 5
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 1 //these are meant to be very rare
	max_occurrences = 1

/datum/round_event/antagonist/solo/clown_operative
	excute_round_end_reports = TRUE
	end_when = 60000 /// we will end on our own when revs win
	var/static/datum/team/nuclear/nuke_team
	var/set_leader = FALSE
	var/required_role = ROLE_CLOWN_OPERATIVE

/datum/round_event/antagonist/solo/clown_operative/setup()
	. = ..()
	var/obj/machinery/nuclearbomb/syndicate/syndicate_nuke = locate() in GLOB.nuke_list
	if(syndicate_nuke)
		var/turf/nuke_turf = get_turf(syndicate_nuke)
		if(nuke_turf)
			new /obj/machinery/nuclearbomb/syndicate/bananium(nuke_turf)
			qdel(syndicate_nuke)

/datum/round_event/antagonist/solo/clown_operative/add_datum_to_mind(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role.title)
	var/list/items = current_mob.get_equipped_items(TRUE)
	current_mob.unequip_everything()
	for(var/obj/item/item as anything in items)
		qdel(item)

	antag_mind.set_assigned_role(SSjob.GetJobType(/datum/job/clown_operative))
	antag_mind.special_role = ROLE_CLOWN_OPERATIVE

	var/datum/mind/most_experienced = get_most_experienced(setup_minds, required_role)
	if(!most_experienced)
		most_experienced = antag_mind

	if(!set_leader)
		set_leader = TRUE
		var/datum/antagonist/nukeop/leader/leader_antag_datum = new()
		nuke_team = leader_antag_datum.nuke_team
		most_experienced.add_antag_datum(leader_antag_datum)
		var/mob/living/carbon/human/leader = most_experienced.current
		leader.equip_species_outfit(/datum/outfit/syndicate/clownop/leader)

	if(antag_mind == most_experienced)
		return

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)


/datum/round_event/antagonist/solo/clown_operative/round_end_report()
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
