/datum/component/plumbing/acclimator
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/acclimator/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(. && istype(parent, /obj/machinery/plumbing/acclimator))
		return TRUE

/datum/component/plumbing/acclimator/can_give(amount, reagent)
	. = ..()
	if(.)
		var/obj/machinery/plumbing/acclimator/AC = parent
		if(AC.reagents.chem_temp >= AC.target_temperature && AC.target_temperature + AC.allowed_temperature_difference >= AC.reagents.chem_temp) //cooling here
			return TRUE
		if(AC.reagents.chem_temp <= AC.target_temperature && AC.target_temperature - AC.allowed_temperature_difference <= AC.reagents.chem_temp) //heating here
			return TRUE
	return FALSE