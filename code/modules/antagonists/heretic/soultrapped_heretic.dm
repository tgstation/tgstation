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

// always failure obj
/datum/objective/heretic_trapped
	name = "soultrapped failure"
	explanation_text = "Help the cult. Kill the cult. Help the crew. Kill the crew. Help your wielder. Kill your wielder. Kill everyone. Rattle your chains."

/datum/antagonist/soultrapped_heretic/on_gain()
	..()
	var/datum/objective/epic_fail = new /datum/objective/heretic_trapped()
	epic_fail.completed = FALSE
	objectives += epic_fail
