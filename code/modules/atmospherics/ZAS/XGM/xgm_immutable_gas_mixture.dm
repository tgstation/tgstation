/datum/gas_mixture/immutable
	temperature = TCMB
	var/initial_temperature = TCMB

/datum/gas_mixture/immutable/update_values()
	temperature = initial_temperature
	return ..()

/datum/gas_mixture/immutable/adjust_gas(gasid, moles, update = 1)
	return

/datum/gas_mixture/immutable/remove()
	return new type

/datum/gas_mixture/immutable/add()
	return TRUE

/datum/gas_mixture/immutable/subtract()
	return TRUE

/datum/gas_mixture/immutable/divide()
	return TRUE

/datum/gas_mixture/immutable/multiply()
	return TRUE

/datum/gas_mixture/immutable/adjust_gas_temp(gasid, moles, temp, update = 1)
	return

/datum/gas_mixture/immutable/adjust_multi()
	return

/datum/gas_mixture/immutable/adjust_multi_temp()
	return

/datum/gas_mixture/immutable/merge()
	return

/datum/gas_mixture/immutable/copy_from()
	return

/datum/gas_mixture/immutable/heat_capacity()
	return HEAT_CAPACITY_VACUUM

/datum/gas_mixture/immutable/remove_ratio()
	return new type

/datum/gas_mixture/immutable/remove_volume()
	return new type

/datum/gas_mixture/immutable/remove_by_flag()
	return new type

/datum/gas_mixture/immutable/share_ratio(datum/gas_mixture/other, connecting_tiles, share_size, one_way)
	. = ..()
	temperature = initial_temperature


