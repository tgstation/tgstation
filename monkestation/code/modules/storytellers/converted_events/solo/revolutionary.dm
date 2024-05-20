/datum/round_event_control/antagonist/solo/revolutionary
	name = "Roundstart Revolution"
	tags = list(TAG_COMMUNAL, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG)
	antag_flag = ROLE_REV_HEAD
	antag_datum = /datum/antagonist/rev/head/event_trigger
	typepath = /datum/round_event/antagonist/solo/revolutionary
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
	base_antags = 2
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	required_enemies = 6
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 3 //value was 3, we need to manually test if this works or not before allowing it normally
	max_occurrences = 1

/datum/antagonist/rev/head/event_trigger
	remove_clumsy = TRUE
	give_flash = TRUE

/datum/round_event/antagonist/solo/revolutionary
	excute_round_end_reports = TRUE
	end_when = 60000 /// we will end on our own when revs win
	var/static/datum/team/revolution/revolution
	var/static/finished = FALSE

/datum/round_event/antagonist/solo/revolutionary/setup()
	. = ..()
	if(!revolution)
		revolution = new()

/datum/round_event/antagonist/solo/revolutionary/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.add_antag_datum(antag_datum, revolution)
	if(length(revolution.members))
		revolution.update_objectives()
		revolution.update_heads()
		SSshuttle.registerHostileEnvironment(revolution)


/datum/round_event/antagonist/solo/revolutionary/round_end_report()
	revolution.round_result(finished)

/datum/round_event/antagonist/solo/revolutionary/tick()
	if(finished)
		return
	var/winner = revolution.process_victory()
	if(isnull(winner))
		return

	finished = winner
	end()
