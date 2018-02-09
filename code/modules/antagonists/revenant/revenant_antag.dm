/datum/antagonist/revenant
	name = "Revenant"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/revenant/greet()
	SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
	owner.announce_objectives()

/datum/antagonist/revenant/proc/forge_objectives()
		var/datum/objective/revenant/objective = new
		objective.owner = mind
		objectives += objective
		var/datum/objective/revenantFluff/objective2 = new
		objective2.owner = mind
		objectives += objective2
	return

/datum/antagonist/revenant/on_gain()
		forge_objectives()
		. = ..()