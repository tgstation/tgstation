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
	explanation_text = "Remember ventcrawl! Using alt+click on vents to quickly travel about the station. Consume energy from the living, corpses have no energy, Drag yourself onto them to feed, Then multiply yourself and spread throughout the station. You are weak to fire extinguishers, stealth and surprise will be your aid."

/datum/objective/pyro_slime/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/pyro_slime/forge_objectives()
	var/datum/objective/pyro_slime/objective = new
	objective.owner = owner
	objectives += objective
