/datum/component/plumbing/acclimator
	demand_connects = WEST
	supply_connects = EAST
	var/obj/machinery/plumbing/acclimator/myacclimator

/datum/component/plumbing/acclimator/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/acclimator))
		return COMPONENT_INCOMPATIBLE
	myacclimator = parent

/datum/component/plumbing/acclimator/Destroy(force, silent)
	myacclimator = null
	return ..()

/datum/component/plumbing/acclimator/can_give(amount, reagent)
	. = ..()
	if(. && myacclimator.emptying)
		return TRUE
	return FALSE
///We're overriding process and not send_request, because all process does is do the requests, so we might aswell cut out the middle man and save some code from running
/datum/component/plumbing/acclimator/process()
	if(myacclimator.emptying)
		return
	return ..()
