/datum/antagonist/revenant
	name = "\improper Revenant"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HORRORS

/datum/antagonist/revenant/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/revenant/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/revenant/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/simple/mob.dmi', "revenant_idle"))

/datum/antagonist/revenant/forge_objectives()
	var/datum/objective/revenant/objective = new
	objective.owner = owner
	objectives += objective
	var/datum/objective/revenant_fluff/objective2 = new
	objective2.owner = owner
	objectives += objective2
