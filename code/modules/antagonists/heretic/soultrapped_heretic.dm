///a heretic that got soultrapped by cultists. does nothing, other than signify they suck
/datum/antagonist/soultrapped_heretic
	name = "\improper Soultrapped Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	job_rank = ROLE_HERETIC
	antag_moodlet = /datum/mood_event/soultrapped_heretic
	antag_hud_name = "heretic"

// Will never show up because they're shades inside a sword
/datum/mood_event/soultrapped_heretic
	description = "They trapped me! I can't escape!"
	mood_change = -20

