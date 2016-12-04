var/list/hardcoded_gases = list("o2","n2","co2","plasma") //the main four gases, which were at one time hardcoded

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list in gas_mixture||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/tile_effects.dmi
	var/moles_visible = null

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
	gas_overlay = "plasma"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/freon
	id = "freon"
	specific_heat = 2000
	name = "Freon"
	gas_overlay = "freon"
	moles_visible = MOLES_PLASMA_VISIBLE

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = 1

/datum/gas/oxygen_agent_b
	id = "agent_b"
	specific_heat = 300
	name = "Oxygen Agent B"

/datum/gas/volatile_fuel
	id = "v_fuel"
	specific_heat = 30
	name = "Volatile Fuel"

/datum/gas/bz
	id = "bz"
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