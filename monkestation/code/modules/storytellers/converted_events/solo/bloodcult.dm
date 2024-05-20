/datum/round_event_control/antagonist/solo/bloodcult
	name = "Blood Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_MAGICAL)
	antag_flag = ROLE_CULTIST
	antag_datum = /datum/antagonist/cult
	typepath = /datum/round_event/antagonist/solo/bloodcult
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 5
	base_antags = 2
	maximum_antags = 3
	// I give up, just there should be enough heads with 35 players...
	min_players = 30
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 4
	max_occurrences = 1

/datum/round_event/antagonist/solo/bloodcult
	excute_round_end_reports = TRUE
	end_when = 60000
	var/static/datum/team/cult/main_cult

/datum/round_event/antagonist/solo/bloodcult/setup()
	. = ..()
	if(!main_cult)
		main_cult = new()

/datum/round_event/antagonist/solo/bloodcult/start()
	. = ..()
	main_cult.setup_objectives()

/datum/round_event/antagonist/solo/bloodcult/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/cult/new_cultist = new antag_datum()
	new_cultist.cult_team = main_cult
	new_cultist.give_equipment = TRUE
	antag_mind.add_antag_datum(new_cultist)

//TEMP REMOVAL FOR TESTING
/*/datum/round_event/antagonist/solo/bloodcult/round_end_report()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
		return

	SSticker.mode_result = "loss - staff stopped the cult"

	if(main_cult.size_at_maximum == 0)
		CRASH("Cult team existed with a size_at_maximum of 0 at round end!")

	// If more than a certain ratio of our cultists have escaped, give the "cult escape" resport.
	// Otherwise, give the "cult failure" report.
	var/ratio_to_be_considered_escaped = 0.5
	var/escaped_cultists = 0
	for(var/datum/mind/escapee as anything in main_cult.members)
		if(considered_escaped(escapee))
			escaped_cultists++

	SSticker.news_report = (escaped_cultists / main_cult.size_at_maximum) >= ratio_to_be_considered_escaped ? CULT_ESCAPE : CULT_FAILURE*/
