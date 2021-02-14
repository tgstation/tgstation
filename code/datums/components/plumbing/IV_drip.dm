///Component that feeds whatever it's supplied with to whoever is buckled to it. Can be safely added to whatever like the others, like chairs or something
/datum/component/plumbing/IV_drip
	demand_connects = SOUTH
	supply_connects = NORTH

	methods = INJECT

/datum/component/plumbing/IV_drip/Initialize()
	. = ..()

	RegisterSignal(parent, list(COMSIG_IV_ATTACH), .proc/update_attached)
	RegisterSignal(parent, list(COMSIG_IV_DETACH), .proc/clear_attached)

	recipient_reagents_holder = null

/datum/component/plumbing/IV_drip/proc/update_attached(datum/source, mob/living/attachee)
	if(attachee?.reagents)
		recipient_reagents_holder = attachee.reagents

/datum/component/plumbing/IV_drip/proc/clear_attached(datum/source)
	recipient_reagents_holder = null
