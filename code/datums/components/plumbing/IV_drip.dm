///Component for IVs that tracks the current person being IV'd. Input received through plumbing is instead routed to the whoever is attached
/datum/component/plumbing/iv_drip
	demand_connects = SOUTH
	supply_connects = NORTH

	methods = INJECT

/datum/component/plumbing/iv_drip/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()

	set_recipient_reagents_holder(null)

/datum/component/plumbing/iv_drip/RegisterWithParent()
	. = ..()

	RegisterSignal(parent, COMSIG_IV_ATTACH, PROC_REF(update_attached))
	RegisterSignal(parent, COMSIG_IV_DETACH, PROC_REF(clear_attached))

/datum/component/plumbing/iv_drip/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_IV_ATTACH)
	UnregisterSignal(parent, COMSIG_IV_DETACH)

///When an IV is attached, we will use whoever is attached as our receiving container
/datum/component/plumbing/iv_drip/proc/update_attached(datum/source, mob/living/attachee)
	SIGNAL_HANDLER

	if(attachee?.reagents)
		set_recipient_reagents_holder(attachee.reagents)

///IV has been detached, so clear the holder
/datum/component/plumbing/iv_drip/proc/clear_attached(datum/source)
	SIGNAL_HANDLER

	set_recipient_reagents_holder(null)
