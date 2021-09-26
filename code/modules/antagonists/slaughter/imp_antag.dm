/**
 * ## Imps
 *
 * Imps used to be summoned by a devil ascending to their final form, but now they're just
 * kinda sitting in limbo... Well, whatever! They're kinda cool anyways!
 */
/datum/antagonist/imp
	name = "Imp"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE

/datum/antagonist/imp/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/imp/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Try to get a promotion to a higher devilish rank."
	newobjective.owner = owner
	objectives += newobjective
