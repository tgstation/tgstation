GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/stimulum, /datum/gas/nitryl))) //unable to react amongst themselves

/proc/meta_gas_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/list/gas_info = new(7)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_SPECIFIC_HEAT] = initial(gas.specific_heat)
		gas_info[META_GAS_NAME] = initial(gas.name)
		gas_info[META_GAS_MOLES_VISIBLE] = initial(gas.moles_visible)
		if(initial(gas.moles_visible) != null)
			gas_info[META_GAS_OVERLAY] = new /obj/effect/overlay/gas(initial(gas.gas_overlay))
		gas_info[META_GAS_FUSION_POWER] = initial(gas.fusion_power)
		gas_info[META_GAS_DANGER] = initial(gas.dangerous)
		gas_info[META_GAS_ID] = initial(gas.id)
		.[gas_path] = gas_info

/proc/gas_id2path(id)
	var/list/meta_gas = GLOB.meta_gas_info
	if(id in meta_gas)
		return id
	for(var/path in meta_gas)
		if(meta_gas[path][META_GAS_ID] == id)
			return path
	return ""

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/tile_effects.dmi
	var/moles_visible = null
	var/dangerous = FALSE //currently used by canisters
	var/fusion_power = 0 //How much the gas accelerates a fusion reaction

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
	fusion_power = 3

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8

/datum/gas/hypernoblium
	id = "nob"
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = 1
	dangerous = TRUE

/datum/gas/nitryl
	id = "no2"
	specific_heat = 20
	name = "Nitryl"
	gas_overlay = "nitryl"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 15

/datum/gas/tritium
	id = "tritium"
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 1

/datum/gas/bz
	id = "bz"
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8

/datum/gas/stimulum
	id = "stim"
	specific_heat = 5
	name = "Stimulum"
	fusion_power = 7

/datum/gas/pluoxium
	id = "pluox"
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = 10

/obj/effect/overlay/gas
	icon = 'icons/effects/tile_effects.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND

/obj/effect/overlay/gas/New(state)
	. = ..()
	icon_state = state
