
/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by helper procs                ||||
\*||||||||||||||||||||||||||||||||||||||||*/

//LOOK AT __DEFINES/atmospherics.dm FOR THE GAS IDs

/datum/gas
	var/id = GAS_INVALID
	var/specific_heat = 0
	var/shorthand = ""	//old keying system
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/tile_effects.dmi
	var/moles_visible = null

/datum/gas/oxygen
	id = GAS_O2
	shorthand = "o2"
	specific_heat = 20
	name = "Oxygen"

/datum/gas/nitrogen
	id = GAS_N2
	shorthand = "n2"
	specific_heat = 20
	name = "Nitrogen"

/datum/gas/carbon_dioxide //what the fuck is this?
	id = GAS_CO2
	shorthand = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"

/datum/gas/plasma
	id = GAS_PLASMA
	specific_heat = 200
	shorthand = "plasma"
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/water_vapor
	id = GAS_WV
	specific_heat = 40
	shorthand = "water_vapor"
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/freon
	id = GAS_FREON
	specific_heat = 2000
	shorthand = "freon"
	name = "Freon"
	gas_overlay = "freon"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/nitrous_oxide
	id = GAS_N2O
	specific_heat = 40
	shorthand = "n2o"
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = 1

/datum/gas/oxygen_agent_b
	id = GAS_AGENTB
	specific_heat = 300
	shorthand = "agent_b"
	name = "Oxygen Agent B"

/datum/gas/volatile_fuel
	id = GAS_VF
	specific_heat = 30
	shorthand = "v_fuel"
	name = "Volatile Fuel"

/datum/gas/bz
	id = GAS_BZ
	shorthand = "bz"
	specific_heat = 20
	name = "BZ"

/obj/effect/overlay/gas
	icon = 'icons/effects/tile_effects.dmi'
	mouse_opacity = 0
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND

/obj/effect/overlay/gas/New(state)
	. = ..()
	icon_state = state

/proc/gasid2shorthand(id)
	switch(id)
		if(GAS_O2)
			return "o2"
		if(GAS_N2)
			return "n2"
		if(GAS_CO2)
			return "co2"
		if(GAS_PLASMA)
			return "plasma"
		if(GAS_WV)
			return "water_vapor"
		if(GAS_BZ)
			return "bz"
		if(GAS_VF)
			return "v_fuel"
		if(GAS_FREON)
			return "freon"
		if(GAS_AGENTB)
			return "agent_b"
		if(GAS_N2O)
			return "n2o"
	return FALSE


/proc/shorthand2gasid(shorthand)
	switch(shorthand)
		if("o2")
			return GAS_O2
		if("n2")
			return GAS_N2
		if("co2")
			return GAS_CO2
		if("plasma")
			return GAS_PLASMA
		if("water_vapor")
			return GAS_WV
		if("bz")
			return GAS_BZ
		if("v_fuel")
			return GAS_VF
		if("freon")
			return GAS_FREON
		if("agent_b")
			return GAS_AGENTB
		if("n2o")
			return GAS_N2O
	return FALSE