// Atmos types used for planetary airs
/datum/atmos/lavaland
	id = LAVALAND_DEFAULT_ATMOS

	base_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/nitrogen=10,
		/datum/gas/carbon_dioxide=10,
	)
	restricted_gases = list(
		/datum/gas/bz=10,
		/datum/gas/miasma=10,
		/datum/gas/nitrous_oxide=10,
		/datum/gas/plasma=0.1,
		/datum/gas/water_vapor=1,
	)
	restricted_chance = 50

	minimum_pressure = HAZARD_LOW_PRESSURE + 1
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = 200
	maximum_temp = 500
