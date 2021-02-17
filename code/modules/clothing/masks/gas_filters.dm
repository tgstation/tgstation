/obj/item/gas_filter
	name = "atmospheric gas filter"
	desc = "piece of filtering cloth to be used with atmospheric gas masks and emergency gas masks"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_atmos_filter"
	var/filter_status = 100
	var/filter_strenght_high = 10
	var/filter_strenght_mid = 8
	var/filter_strenght_low = 5
	var/filter_efficiency = 0.5

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

	var/list/gases_moles = list(
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

	var/list/high_filtering_gases = list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide
	)

	var/list/mid_filtering_gases = list(
		/datum/gas/nitryl,
		/datum/gas/stimulum,
		/datum/gas/freon,
		/datum/gas/hypernoblium,
		/datum/gas/bz
	)

	var/list/low_filtering_gases = list(
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/halon,
		/datum/gas/tritium,
		/datum/gas/zauker
	)

/obj/item/gas_filter/proc/reduce_filter_status(datum/gas_mixture/breath)

	for(var/gasID in gases_to_check)
		breath.assert_gas(gasID)

	for(var/gasID in gases_to_check)
		gases_moles[gasID] = breath.gases[gasID][MOLES]

	var/danger_points = 0

	for(var/gasID in high_filtering_gases)
		if(gases_moles[gasID] > 0.005)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_high * filter_efficiency * 0.001, 0)
			danger_points += 0.5
		else if(gases_moles[gasID] > 0)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_high * filter_efficiency * 0.0005, 0)
			danger_points += 0.05

	for(var/gasID in mid_filtering_gases)
		if(gases_moles[gasID] > 0.0025)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_mid * filter_efficiency * 0.001, 0)
			danger_points += 0.75
		else if(gases_moles[gasID] > 0)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_mid * filter_efficiency * 0.0005, 0)
			danger_points += 0.15

	for(var/gasID in low_filtering_gases)
		if(gases_moles[gasID] > 0.001)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_low * filter_efficiency * 0.001, 0)
			danger_points += 1
		else if(gases_moles[gasID] > 0)
			breath.gases[gasID][MOLES] = max(breath.gases[gasID][MOLES] - filter_strenght_low * filter_efficiency * 0.0005, 0)
			danger_points += 0.5

	filter_status = max(filter_status - danger_points - 1, 0)
	return breath
