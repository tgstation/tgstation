GLOBAL_LIST_INIT(thermomachine_datums, thermomachine_datums_list())

/*
 * Global proc to build the electrolyzer datum list
 */
/proc/thermomachine_datums_list()
	var/list/buil_datum_list = list()
	for(var/datum_path in subtypesof(/datum/thermomachine_datums))
		var/datum/thermomachine_datums/datum = new datum_path()

		buil_datum_list[datum.id] = datum

	return buil_datum_list

/datum/thermomachine_datums
	var/list/requirements
	var/name = "reaction"
	var/id = "r"

/datum/thermomachine_datums/proc/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	return

/datum/thermomachine_datums/proc/reaction_check(datum/gas_mixture/air_mixture)
	var/temp = air_mixture.temperature
	var/list/cached_gases = air_mixture.gases
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/id in requirements)
		if (id == "MIN_TEMP" || id == "MAX_TEMP")
			continue
		if(!cached_gases[id] || cached_gases[id][MOLES] < requirements[id])
			return FALSE
	return TRUE

