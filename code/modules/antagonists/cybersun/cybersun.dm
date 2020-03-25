/datum/team/cybersun
	name = "Cybersun Crew"
	show_roundend_report = FALSE

/datum/antagonist/cybersun
	name = "Cybersun Crewmember"
	antagpanel_category = "GhostCybersun"
	job_rank = ROLE_SYNDICATE_CYBERSUN
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER //Just in case
	var/datum/team/cybersun/cybersun_team

/datum/antagonist/cybersun/get_team()
	return cybersun_team

/datum/antagonist/cybersun/captain
	name = "Cybersun Captain"