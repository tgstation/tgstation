var/global/list/gas_datum_list

/datum/gas
	var/display_name = ""
	var/display_short = ""

	var/gas_id = "" //all ids must be unique

	var/specific_heat = 0

	var/gas_flags = 0
	var/fuel_multiplier = 1 //multiplier of rate of burning

/datum/gas/proc/isFuel()
	return gas_flags & IS_FUEL

/datum/gas/proc/isOxidiser()
	return gas_flags & IS_OXIDISER

/datum/gas/oxygen
	display_name = "Oxygen"
	display_short = "O2"
	gas_id = OXYGEN
	specific_heat = SPECIFIC_HEAT_AIR
	gas_flags = IS_OXIDISER | ALWAYS_SHOW

/datum/gas/nitrogen
	display_name = "Nitrogen"
	display_short = "N2"
	gas_id = NITROGEN
	specific_heat = SPECIFIC_HEAT_AIR
	gas_flags = ALWAYS_SHOW

/datum/gas/plasma
	display_name = "Plasma"
	display_short = "PL"
	gas_id = PLASMA
	specific_heat = SPECIFIC_HEAT_PLASMA
	gas_flags = IS_FUEL | AUTO_FILTERED | AUTO_LOGGING | ALWAYS_SHOW
	fuel_multiplier = 3

/datum/gas/co2
	display_name = "Carbon Dioxide"
	display_short = "CO2"
	gas_id = CARBON_DIOXIDE
	specific_heat = SPECIFIC_HEAT_CDO
	gas_flags = AUTO_FILTERED | AUTO_LOGGING | ALWAYS_SHOW

/datum/gas/n2o
	display_name = "Nitrous Oxide"
	display_short = "N2O"
	gas_id = NITROUS_OXIDE
	specific_heat = SPECIFIC_HEAT_NIO
	gas_flags = AUTO_FILTERED | AUTO_LOGGING

//ping me when someone figures out what the hell this is for
/*
/datum/gas/oxygen_agent_b
	display_name = "Oxygen Agent B"
	display_short = "OAB"
	gas_id = "oxygen_agent_b"
	specific_heat = 300
*/

/datum/gas/volatile_fuel
	display_name = "Volatile Fuel"
	display_short = "VF"
	gas_id = VOLATILE_FUEL
	specific_heat = 30
	gas_flags = IS_FUEL | AUTO_LOGGING
	fuel_multiplier = 5

