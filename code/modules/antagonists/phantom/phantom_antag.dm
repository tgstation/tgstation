/datum/antagonist/phantom
	name = "\improper Phantom"
	pref_flag = ROLE_PHANTOM
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HORRORS

/datum/antagonist/phantom/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/phantom/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/phantom/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/simple/mob.dmi', "phantom_idle"))

/datum/antagonist/phantom/forge_objectives()
	var/datum/objective/phantom/objective = new
	objective.owner = owner
	objectives += objective
	var/datum/objective/phantom_fluff/objective2 = new
	objective2.owner = owner
	objectives += objective2
