/datum/component/plumbing/milker
	demand_connects = SOUTH
	supply_connects = NORTH

/datum/component/plumbing/Initialize()
	. = ..()

	RegisterSignal(parent, list(COMSIG_LIVING_SET_BUCKLED), .proc/update_buckled)
	reagents = null

/datum/component/plumbing/milker/proc/update_buckled(datum/source, bucklee)
	if(isatom(bucklee))
		var/atom/A = bucklee
		if(A.reagents)
			reagents = A.reagents
			START_PROCESSING(SSfluids, src) //Component might've stopped processing if we didn't have a reagent holder before
	else
		reagents = null
