//"immutable" gas mixture used for space calculations
//it can be changed, but any changes will ultimately be undone before they can have any effect
#define SPACE_MIX_HEAT_CAP 7000
#define GET_SPACE_MIX PoolOrNew(/datum/gas_mixture/space)

/datum/gas_mixture/space

/datum/gas_mixture/space/New()
	..()
	temperature = TCMB
	temperature_archived = TCMB

/datum/gas_mixture/space/garbage_collect()
	gases = INIT_GASES

/datum/gas_mixture/space/archive()
	return 1 //nothing changes, so we do nothing and the archive is successful

/datum/gas_mixture/space/merge(giver, delete_after = TRUE)
	if(delete_after)
		qdel(giver)
	return 0 //we're immutable.

/datum/gas_mixture/space/heat_capacity()
	. = SPACE_MIX_HEAT_CAP

/datum/gas_mixture/space/heat_capacity_archived()
	. = SPACE_MIX_HEAT_CAP

/datum/gas_mixture/space/remove()
	return GET_SPACE_MIX //we're immutable, so we can just return a copy.

/datum/gas_mixture/space/remove_ratio()
	return GET_SPACE_MIX //we're immutable, so we can just return a copy.

/datum/gas_mixture/space/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = ..(sharer, 0)
	temperature = TCMB
	gases = INIT_GASES

/datum/gas_mixture/space/after_share()
	temperature = TCMB
	gases = INIT_GASES

/datum/gas_mixture/space/react()
	return 0 //we're immutable.

/datum/gas_mixture/space/fire()
	return 0 //we're immutable.

/datum/gas_mixture/space/copy()
	return GET_SPACE_MIX //we're immutable, so we can just return a new instance.

/datum/gas_mixture/space/copy_from()
	return 0 //we're immutable.

/datum/gas_mixture/space/copy_from_turf()
	return 0 //we're immutable.

/datum/gas_mixture/space/parse_gas_string()
	return 0 //we're immutable.

/datum/gas_mixture/space/temperature_share(datum/gas_mixture/sharer, conduction_coefficient, sharer_temperature, sharer_heat_capacity)
	. = ..()
	temperature = TCMB
