/obj/item/gas_filter
	name = "atmospheric gas filter"
	desc = "piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_atmos_filter"
	var/filter_status = 100

	var/list/gases_to_check = list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide,
		/datum/gas/bz,
		/datum/gas/tritium,
		/datum/gas/nitryl,
		/datum/gas/stimulum,
		/datum/gas/freon,
		/datum/gas/hypernoblium,
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/zauker,
		/datum/gas/halon
	)

	var/list/gas_pp = list(
		/datum/gas/plasma = 0,
		/datum/gas/carbon_dioxide = 0,
		/datum/gas/nitrous_oxide = 0,
		/datum/gas/bz = 0,
		/datum/gas/tritium = 0,
		/datum/gas/nitryl = 0,
		/datum/gas/stimulum = 0,
		/datum/gas/freon = 0,
		/datum/gas/hypernoblium = 0,
		/datum/gas/healium = 0,
		/datum/gas/proto_nitrate = 0,
		/datum/gas/zauker = 0,
		/datum/gas/halon = 0
	)

	var/list/low_danger_gases = list(
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/halon,
		/datum/gas/bz
	)

	var/list/mid_danger_gases = list(
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide,
		/datum/gas/nitryl,
		/datum/gas/stimulum,
		/datum/gas/freon,
		/datum/gas/hypernoblium
	)

	var/list/high_danger_gases = list(
		/datum/gas/plasma,
		/datum/gas/tritium,
		/datum/gas/zauker
	)

/obj/item/gas_filter/proc/reduce_filter_status(datum/gas_mixture/breath)

	for(var/gasID in gases_to_check)
		breath.assert_gas(gasID)

	for(var/gasID in gases_to_check)
		gas_pp[gasID] = max(breath.get_breath_partial_pressure(breath.gases[gasID][MOLES]), 0)

	var/danger_points = 0

	for(var/gasID in low_danger_gases)
		if(gas_pp[gasID][MOLES] > 5)
			danger_points += 0.5
		else if(gas_pp[gasID][MOLES] > 0)
			danger_points += 0.05

	for(var/gasID in mid_danger_gases)
		if(gas_pp[gasID][MOLES] > 2.5)
			danger_points += 0.75
		else if(gas_pp[gasID][MOLES] > 0)
			danger_points += 0.15

	for(var/gasID in high_danger_gases)
		if(gas_pp[gasID][MOLES] > 1)
			danger_points += 1
		else if(gas_pp[gasID][MOLES] > 0)
			danger_points += 0.5

	filter_status = max(filter_status - danger_points - 1, 0)
