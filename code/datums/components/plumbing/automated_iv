/datum/component/plumbing/automated_iv
	demand_connects = SOUTH
	supply_connects = NORTH
	var/obj/machinery/iv_drip/plumbing/myivdrip

/datum/component/plumbing/automated_iv/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/iv_drip/plumbing))
		return COMPONENT_INCOMPATIBLE
	myivdrip = parent

/datum/component/plumbing/automated_iv/Destroy(force)
	myivdrip = null
	return ..()

/datum/component/plumbing/automated_iv/can_give(amount, reagent)
	. = ..()
	if(. && myivdrip.mode == 0)
		return TRUE
	return FALSE

/datum/component/plumbing/automated_iv/send_request(dir)
    if(myivdrip.mode == 1)
        process_request(dir = dir)
        return TRUE
    return FALSE
