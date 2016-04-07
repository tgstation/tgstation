//"immutable" gas mixture used for space calculations
//it can be changed, but any changes will ultimately be undone before they can have any effect

/datum/gas_mixture/space
	var/static/datum/gas_mixture/dummy = new

/datum/gas_mixture/space/New()
	..()
	temperature = TCMB
	temperature_archived = TCMB

/datum/gas_mixture/space/garbage_collect()
	gases.Cut() //clever way of ensuring we always are empty.

/datum/gas_mixture/space/archive()
	return 1 //nothing changes, so we do nothing and the archive is successful

/datum/gas_mixture/space/merge()
	return 0 //we're immutable.

/datum/gas_mixture/space/remove()
	return copy() //we're immutable, so we can just return a copy.

/datum/gas_mixture/space/remove_ratio()
	return copy() //we're immutable, so we can just return a copy.

/datum/gas_mixture/space/share(datum/gas_mixture/sharer, atmos_adjacent_turfs = 4)
	. = dummy.share(sharer, atmos_adjacent_turfs) //keep all the sharing calculations, but don't actually change anything about ourselves
	dummy.copy_from(src)

/datum/gas_mixture/space/after_share()
	temperature = TCMB
	gases.Cut()

/datum/gas_mixture/space/react()
	return 0 //we're immutable.

/datum/gas_mixture/space/fire()
	return 0 //we're immutable.

/datum/gas_mixture/space/copy()
	return new /datum/gas_mixture/space //we're immutable, so we can just return a new instance.

/datum/gas_mixture/space/copy_from()
	return 0 //we're immutable.

/datum/gas_mixture/space/copy_from_turf()
	return 0 //we're immutable.

/datum/gas_mixture/space/parse_gas_string()
	return 0 //we're immutable.

/datum/gas_mixture/space/temperature_share()
	..()
	temperature = TCMB
