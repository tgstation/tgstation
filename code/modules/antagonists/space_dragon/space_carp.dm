/datum/antagonist/space_carp
	name = "\improper Space Carp"
	antagpanel_category = "Transdimensional Horrors"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// The rift to protect
	var/obj/structure/carp_rift/rift

/datum/antagonist/space_carp/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/space_carp/greet()
	. = ..()
	owner.announce_objectives()

/datum/objective/space_carp
	explanation_text = "Protect the rift to summon more carps."
	var/obj/structure/carp_rift/rift

/datum/objective/space_carp/check_completion()
	if(!rift)
		return FALSE
	return TRUE

/// Create new objectives
/datum/antagonist/space_carp/forge_objectives()
	var/datum/objective/space_carp/objective = new
	objective.owner = owner
	objective.rift = rift
	objectives += objective
