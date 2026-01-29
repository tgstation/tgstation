/datum/component/plumbing/acclimator
	demand_connects = WEST
	supply_connects = EAST
	var/obj/machinery/plumbing/acclimator/myacclimator

/datum/component/plumbing/acclimator/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/acclimator))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/acclimator/send_request(dir)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	if(!myacclimator.emptying)
		return ..()

/datum/component/plumbing/acclimator/supply_demand(dir)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	if(!reagents.is_reacting && myacclimator.emptying)
		return ..()
