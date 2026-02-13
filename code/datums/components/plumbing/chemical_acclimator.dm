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
	if(myacclimator.acclimate_state == AC_FILLING)
		if(reagents.total_volume < myacclimator.max_volume)
			. = ..()
			if(!reagents.holder_full())
				return
		myacclimator.acclimate_state = reagents.chem_temp > myacclimator.target_temperature ? AC_COOLING : AC_HEATING
		myacclimator.update_appearance(UPDATE_ICON_STATE)

/datum/component/plumbing/acclimator/can_give(amount, reagent)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent

	return myacclimator.acclimate_state == AC_EMPTYING && !reagents.is_reacting && ..()
