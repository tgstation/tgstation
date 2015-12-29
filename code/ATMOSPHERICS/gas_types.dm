var/list/hardcoded_gases = list("o2","n2","co2","plasma") //the main four gases, which were at one time hardcoded

/proc/meta_gas_list()
	. = new /list
	var/i = 1

	var/datum/gas/prototype = /datum/gas
	var/list/gas_vars = initial(prototype.vars)

	for(var/gas_path in subtypesof(/datum/gas))
		var/list/gas_info = new
		var/datum/gas/g = gas_path
		for(var/v in gas_vars)
			gas_info += initial(g.vars[v])

		/*
		gas_info += initial(g.id)
		gas_info += initial(g.specific_heat)
		gas_info += initial(g.name)
		*/
		.[i] = gas_info
		i++

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated, ||||
||||except once in meta_gas_list(). This||||
||||particular instance is deleted after||||
||||accessing one var, which cannot be  ||||
||||accessed by abusing initial().      ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""

/datum/gas/oxygen
	id = "o2"
	specific_heat = 20
	name = "Oxygen"

/datum/gas/nitrogen
	id = "n2"
	specific_heat = 20
	name = "Nitrogen"

/datum/gas/carbon_dioxide //what the fuck is this?
	id = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"

/datum/gas/oxygen_agent_b
	id = "agent_b"
	specific_heat = 300
	name = "Oxygen Agent B"

/datum/gas/volatile_fuel
	id = "v_fuel"
	specific_heat = 30
	name = "Volatile Fuel"
