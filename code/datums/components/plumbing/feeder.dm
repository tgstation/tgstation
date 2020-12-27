///Component that feeds whatever it's supplied with to whoever is buckled to it. Can be safely added to whatever like the others, like chairs or something
/datum/component/plumbing/feeder
	demand_connects = SOUTH
	supply_connects = NORTH

/datum/component/plumbing/feeder/Initialize()
	. = ..()

	RegisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE), .proc/update_buckled)
	RegisterSignal(parent, list(COMSIG_MOVABLE_UNBUCKLE), .proc/clear_buckled)

	recipient_reagents_holder = null

/datum/component/plumbing/feeder/proc/update_buckled(datum/source, mob/living/bucklee)
	if(bucklee?.reagents)
		recipient_reagents_holder = bucklee.reagents
		START_PROCESSING(SSfluids, src) //Component might've stopped processing if we didn't have a reagent holder before

/datum/component/plumbing/feeder/proc/clear_buckled(datum/source)
	recipient_reagents_holder = null
