///Component for IVs that tracks the current person being IV'd. Input received through plumbing is instead routed to the whoever is attached
/datum/component/plumbing/iv_drip
	demand_connects = SOUTH
	supply_connects = NORTH

	methods = INJECT

/datum/component/plumbing/iv_drip/Initialize()
	. = ..()
	
	recipient_reagents_holder = null

/datum/component/plumbing/iv_drip/RegisterWithParent()
	. = ..()

	RegisterSignal(parent, list(COMSIG_IV_ATTACH), .proc/update_attached)
	RegisterSignal(parent, list(COMSIG_IV_DETACH), .proc/clear_attached)

/datum/component/plumbing/iv_drip/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_IV_ATTACH))
	UnregisterSignal(parent, list(COMSIG_IV_DETACH))

///When an IV is attached, we will use whoever is attached as our receiving container
/datum/component/plumbing/iv_drip/proc/update_attached(datum/source, mob/living/attachee)
	SIGNAL_HANDLER

	if(attachee?.reagents)
		recipient_reagents_holder = attachee.reagents

///IV has been detached, so clear the holder
/datum/component/plumbing/iv_drip/proc/clear_attached(datum/source)
	SIGNAL_HANDLER

	recipient_reagents_holder = null
