GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
//Now this is what I call history
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium))) //unable to react amongst themselves

/proc/meta_gas_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/list/gas_info = new(8)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_SPECIFIC_HEAT] = initial(gas.specific_heat)
		gas_info[META_GAS_NAME] = initial(gas.name)

		gas_info[META_GAS_MOLES_VISIBLE] = initial(gas.moles_visible)
		if(initial(gas.moles_visible) != null)
			gas_info[META_GAS_OVERLAY] = new /list(TOTAL_VISIBLE_STATES)
			for(var/i in 1 to TOTAL_VISIBLE_STATES)
				gas_info[META_GAS_OVERLAY][i] = new /obj/effect/overlay/gas(initial(gas.gas_overlay), log(4, (i+0.4*TOTAL_VISIBLE_STATES) / (0.35*TOTAL_VISIBLE_STATES)) * 255)

		gas_info[META_GAS_FUSION_POWER] = initial(gas.fusion_power)
		gas_info[META_GAS_DANGER] = initial(gas.dangerous)
		gas_info[META_GAS_ID] = initial(gas.id)
		gas_info[META_GAS_DESC] = initial(gas.desc)
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

//This is a plot created using the values for gas exports. Each gas has a value that works as it's kind of soft-cap, which limits you from making billions of credits per sale, based on the base_value variable on the gasses themselves. Most of these gasses as a result have a rather low value when sold, like nitrogen and oxygen at 1500 and 600 respectively at their maximum value. The
/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	///icon_state in icons/effects/atmospherics.dmi
	var/gas_overlay = ""
	var/moles_visible = null
	///currently used by canisters
	var/dangerous = FALSE
	///How much the gas accelerates a fusion reaction
	var/fusion_power = 0
	/// relative rarity compared to other gases, used when setting up the reactions list.
	var/rarity = 0
	///Can gas of this type can purchased through cargo?
	var/purchaseable = FALSE
	///How does a single mole of this gas sell for? Formula to calculate maximum value is in code\modules\cargo\exports\large_objects.dm. Doesn't matter for roundstart gasses.
	var/base_value = 0
	var/desc


/datum/gas/oxygen
	id = "o2"
	specific_heat = 20
	name = "Oxygen"
	rarity = 900
	purchaseable = TRUE
	base_value = 0.2
	desc = "The gas most life forms need to be able to survive. Also an oxidizer."

/datum/gas/nitrogen
	id = "n2"
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000
	purchaseable = TRUE
	base_value = 0.1
	desc = "A very common gas that used to pad artifical atmospheres to habitable pressure."

/datum/gas/carbon_dioxide //what the fuck is this?
	id = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"
	dangerous = TRUE
	rarity = 700
	purchaseable = TRUE
	base_value = 0.2
	desc = "What the fuck is carbon dioxide?"

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 800
	base_value = 1.5
	desc = "A flammable gas with many other curious properties. It's research is one of NT's primary objective."

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500
	purchaseable = TRUE
	base_value = 0.5
	desc = "Water, in gas form. Makes things slippery."

/datum/gas/hypernoblium
	id = "nob"
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 10
	rarity = 50
	base_value = 2.5
	desc = "The most noble gas of them all. High quantities of hyper-noblium actively prevents reactions from occuring."

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	dangerous = TRUE
	rarity = 600
	purchaseable = TRUE
	base_value = 1.5
	desc = "Causes drowsiness, euphoria, and eventually unconsciousness."

/datum/gas/nitrium
	id = "nitrium"
	specific_heat = 10
	name = "Nitrium"
	fusion_power = 7
	gas_overlay = "nitrium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 1
	base_value = 6
	desc = "An experimental performance enhancing gas. Nitrium can have amplified effects as more of it gets into your bloodstream."

/datum/gas/tritium
	id = "tritium"
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 5
	rarity = 300
	base_value = 2.5
	desc = "A highly flammable and radioctive gas."

/datum/gas/bz
	id = "bz"
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8
	rarity = 400
	purchaseable = TRUE
	base_value = 1.5
	desc = "A powerful hallucinogenic nerve agent able to induce cognitive damage."

/datum/gas/pluoxium
	id = "pluox"
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	rarity = 200
	base_value = 2.5
	desc = "A gas that could supply even more oxygen to the bloodstream when inhaled, without being an oxidizer."

/datum/gas/miasma
	id = "miasma"
	specific_heat = 20
	name = "Miasma"
	dangerous = TRUE
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	base_value = 1
	desc = "Not necessarily a gas, miasma refers to biological pollutants found in the atmosphere."

/datum/gas/freon
	id = "freon"
	specific_heat = 600
	name = "Freon"
	dangerous = TRUE
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE *30
	fusion_power = -5
	rarity = 10
	base_value = 5
	desc = "A coolant gas. Mainly used for it's endothermic reaction with oxygen."

/datum/gas/hydrogen
	id = "hydrogen"
	specific_heat = 15
	name = "Hydrogen"
	dangerous = TRUE
	fusion_power = 2
	rarity = 600
	base_value = 1
	desc = "A highly flammable gas."

/datum/gas/healium
	id = "healium"
	specific_heat = 10
	name = "Healium"
	dangerous = TRUE
	gas_overlay = "healium"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300
	base_value = 5.5
	desc = "Causes deep, regenerative sleep."

/datum/gas/proto_nitrate
	id = "proto_nitrate"
	specific_heat = 30
	name = "Proto Nitrate"
	dangerous = TRUE
	gas_overlay = "proto_nitrate"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 200
	base_value = 2.5
	desc = "A very volatile gas that reacts differently with various gases."

/datum/gas/zauker
	id = "zauker"
	specific_heat = 350
	name = "Zauker"
	dangerous = TRUE
	gas_overlay = "zauker"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 1
	base_value = 7
	desc = "A highly toxic gas, it's production is highly regulated on top of being difficult. It also breaks down when in contact with nitrogen."

/datum/gas/halon
	id = "halon"
	specific_heat = 175
	name = "Halon"
	dangerous = TRUE
	gas_overlay = "halon"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300
	base_value = 4
	desc = "A potent fire supressant. Removes oxygen from high temperature fires and cools down the area"

/datum/gas/helium
	id = "helium"
	specific_heat = 15
	name = "Helium"
	fusion_power = 7
	rarity = 50
	base_value = 3.5
	desc = "A very inert gas produced by the fusion of hydrogen and it's derivatives."

/datum/gas/antinoblium
	id = "antinoblium"
	specific_heat = 1
	name = "Antinoblium"
	dangerous = TRUE
	gas_overlay = "antinoblium"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 20
	rarity = 1
	base_value = 10
	desc = "We still don't know what it does, but it sells for a lot."

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state, alph)
	. = ..()
	icon_state = state
	alpha = alph
