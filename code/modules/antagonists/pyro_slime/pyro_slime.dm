/datum/antagonist/pyro_slime
	name = "\improper Pyroclastic Anomaly"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

/datum/antagonist/pyro_slime/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/pyro_slime/greet()
	. = ..()
	owner.announce_objectives()

/datum/objective/pyro_slime
	explanation_text = "I am fire. I am hunger. The cold is agony. The living pulse with energy; their warmth fuels me. The dead are husks, their embers long faded. Water is death. Fire... fire is freedom."

/datum/objective/pyro_slime/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/pyro_slime/forge_objectives()
	var/datum/objective/pyro_slime/objective = new
	objective.owner = owner
	objectives += objective
