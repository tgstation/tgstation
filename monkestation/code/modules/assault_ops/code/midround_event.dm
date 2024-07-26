/datum/round_event_control/antagonist/solo/from_ghosts/assault_operative
	name = "Operative Assault"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_ASSAULT_OPERATIVE
	antag_datum = /datum/antagonist/assault_operative
	typepath = /datum/round_event/antagonist/solo/ghost/assault_operative
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
	maximum_antags = 4
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
	earliest_start = 45 MINUTES
	weight = 4
	max_occurrences = 1
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/ghost/assault_operative
	excute_round_end_reports = TRUE
	var/static/datum/team/assault_operatives/assault_team

/datum/round_event/antagonist/solo/ghost/assault_operative/add_datum_to_mind(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role.title)
	var/list/items = current_mob.get_equipped_items(TRUE)
	current_mob.unequip_everything()
	for(var/obj/item/item as anything in items)
		qdel(item)

	antag_mind.set_assigned_role(SSjob.GetJobType(/datum/job/assault_operative))
	antag_mind.special_role = ROLE_ASSAULT_OPERATIVE

	var/datum/antagonist/assault_operative/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)

//this might be able to be kept as just calling parent
/datum/round_event/antagonist/solo/ghost/assault_operative/round_end_report()
	var/result = assault_team.get_result()
	var/list/parts = list()
	parts += "<span class='header'>Assault Operatives:</span>"
	switch(result)
		if(ASSAULT_RESULT_WIN)
			parts += span_greentext("Assault Operatives Major Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, and they all survived!</B>"
		if(ASSAULT_RESULT_PARTIAL_WIN)
			parts += span_greentext("Assault Operatives Minor Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, but only some survived!</B>"
		if(ASSAULT_RESULT_HEARTY_WIN)
			parts += span_greentext("Assault Operatives Hearty Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, but they all died!</B>"
		if(ASSAULT_RESULT_LOSS)
			parts += span_redtext("Crew Victory!")
			parts += "<B>The Research Staff of [station_name()] have killed all of the assault operatives and stopped them activating GoldenEye!</B>"
		if(ASSAULT_RESULT_STALEMATE)
			parts += "<span class='neutraltext big'>Stalemate!</span>"
			parts += "<B>The assault operatives have failed to activate GoldenEye and are still alive!</B>"
		else
			parts += "<span class='neutraltext big'>Neutral Victory</span>"
			parts += "<B>Mission aborted!</B>"
	parts += span_redtext("GoldenEye keys uploaded: [SSgoldeneye.uploaded_keys]/[SSgoldeneye.required_keys]")

	var/text = "<br><span class='header'>The assault operatives were:</span>"
	text += printplayerlist(assault_team.members)
	text += "<br>"

	parts += text

	SSticker.news_report = parts
