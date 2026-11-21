/// Logs the contents of the gasmix to the game log, prefixed by text
/proc/log_atmos(text, datum/gas_mixture/gas_mixture)
	var/message = "[text]\"[print_gas_mixture(gas_mixture)]\""
	//Cache commonly accessed information.
	var/list/cached_moles = gas_mixture.moles
	var/heat_capacity = gas_mixture.heat_capacity()
	var/temperature = gas_mixture.return_temperature()
	var/thermal_energy = temperature * heat_capacity
	var/volume = gas_mixture.return_volume()
	var/pressure = gas_mixture.return_pressure()
	var/total_moles = gas_mixture.total_moles()
	var/list/cached_specific_heat = GAS_META[META_GAS_SPECIFIC_HEAT]
	var/list/cached_gas_name = GAS_META[META_GAS_NAME]
	///The total value of the gas mixture in credits.
	var/total_value = 0
	var/list/specific_gas_data = list()

	//Gas specific information assigned to each gas.
	for(var/datum/gas/gas_path as anything in cached_moles)
		var/moles = cached_moles[gas_path]
		var/composition = moles / total_moles
		var/energy = temperature * moles * cached_specific_heat[gas_path]
		var/value = initial(gas_path.base_value) * moles
		total_value += value
		specific_gas_data[cached_gas_name[gas_path]] = list(
			"moles" = moles,
			"composition" = composition,
			"molar concentration" = moles / volume,
			"partial pressure" = composition * pressure,
			"energy" = energy,
			"energy density" = energy / volume,
			"value" = value,
		)

	log_game(
		message,
		data = list(
			"total moles" = total_moles,
			"volume" = volume,
			"molar density" = total_moles / volume,
			"temperature" = temperature,
			"pressure" = pressure,
			"heat capacity" = heat_capacity,
			"energy" = thermal_energy,
			"energy density" = thermal_energy / volume,
			"value" = total_value,
			"gases" = specific_gas_data,
		)
	)
