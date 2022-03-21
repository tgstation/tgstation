//"immutable" gas mixture used for immutable calculations
//it can be changed, but any changes will ultimately be undone before they can have any effect

/datum/gas_mixture/immutable
	var/initial_temperature
	gc_share = TRUE

/datum/gas_mixture/immutable/New()
	..()
	garbage_collect()

/datum/gas_mixture/immutable/garbage_collect()
	temperature = initial_temperature
	temperature_archived = initial_temperature
	gases.Cut()

/datum/gas_mixture/immutable/archive()
	return TRUE //nothing changes, so we do nothing and the archive is successful

/datum/gas_mixture/immutable/merge()
	return FALSE //we're immutable.

/datum/gas_mixture/immutable/share(datum/gas_mixture/sharer, our_coeff, sharer_coeff)
	. = ..()
	sharer.temperature = initial_temperature
	garbage_collect()

/datum/gas_mixture/immutable/react()
	return FALSE //we're immutable.

/datum/gas_mixture/immutable/copy()
	return new type //we're immutable, so we can just return a new instance.

/datum/gas_mixture/immutable/copy_from()
	return FALSE //we're immutable.

/datum/gas_mixture/immutable/copy_from_turf()
	return FALSE //we're immutable.

/datum/gas_mixture/immutable/parse_gas_string()
	return FALSE //we're immutable.

/datum/gas_mixture/immutable/temperature_share(datum/gas_mixture/sharer, conduction_coefficient, sharer_temperature, sharer_heat_capacity)
	. = ..()
	temperature = initial_temperature

//used by space tiles
/datum/gas_mixture/immutable/space
	initial_temperature = TCMB

/datum/gas_mixture/immutable/space/heat_capacity()
	return HEAT_CAPACITY_VACUUM

/datum/gas_mixture/immutable/space/remove()
	return copy() //we're always empty, so we can just return a copy.

/datum/gas_mixture/immutable/space/remove_ratio()
	return copy() //we're always empty, so we can just return a copy.

//planet side stuff
/datum/gas_mixture/immutable/planetary
	var/list/initial_gas = list()

/datum/gas_mixture/immutable/planetary/garbage_collect()
	..()
	gases.Cut()
	for(var/id in initial_gas)
		ADD_GAS(id, gases)
		gases[id][MOLES] = initial_gas[id][MOLES]
		gases[id][ARCHIVE] = initial_gas[id][ARCHIVE]

/datum/gas_mixture/immutable/planetary/proc/parse_string_immutable(gas_string) //I know I know, I need this tho
	gas_string = SSair.preprocess_gas_string(gas_string)

	var/list/mix = initial_gas
	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		initial_temperature = text2num(gas["TEMP"])
		temperature_archived = initial_temperature
		temperature = initial_temperature
		gas -= "TEMP"
	mix.Cut()
	for(var/id in gas)
		var/path = id
		if(!ispath(path))
			path = gas_id2path(path) //a lot of these strings can't have embedded expressions (especially for mappers), so support for IDs needs to stick around
		ADD_GAS(path, mix)
		mix[path][MOLES] = text2num(gas[id])
		mix[path][ARCHIVE] = mix[path][MOLES]

	for(var/id in mix)
		ADD_GAS(id, gases)
		gases[id][MOLES] = mix[id][MOLES]
		gases[id][ARCHIVE] = mix[id][MOLES]


