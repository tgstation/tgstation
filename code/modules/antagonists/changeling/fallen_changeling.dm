///a changeling that has lost their powers. does nothing, other than signify they suck
/datum/antagonist/fallen_changeling
	name = "\improper Fallen Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	job_rank = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/fallen_changeling
	antag_hud_name = "changeling"

/datum/mood_event/fallen_changeling
	description = "<span class='warning'>My powers! Where are my powers?!</span>\n"
	mood_change = -4

