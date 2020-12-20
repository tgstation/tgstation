GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/stimulum, /datum/gas/nitryl))) //unable to react amongst themselves

/proc/meta_gas_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/list/gas_info = new(13)
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

		gas_info[META_GAS_COND_RATE] = initial(gas.cond_rate)
		gas_info[META_GAS_COND_TEMP_MAX] = initial(gas.cond_temp_max)
		gas_info[META_GAS_COND_TEMP_MIN] = initial(gas.cond_temp_min)
		gas_info[META_GAS_COND_TYPE] = initial(gas.cond_type)
		gas_info[META_GAS_COND_HEAT] = initial(gas.cond_heat)

		if(GLOB.gas_singletons) // We do this twice to make sure it gets in regardless of which order these are instantiated
			var/datum/gas/gas_singleton = GLOB.gas_singletons[gas_path]
			gas_singleton.meta_gas_list = gas_info
			gas_info[META_GAS_COND_EVENT] = gas_singleton.cond_event

		.[gas_path] = gas_info

	if(SSair)
		SSair.gas_metadata = .

/proc/init_gas_singletons()
	. = list()
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/gas_singleton = new gas_path
		.[gas_path] = gas_singleton

		if(GLOB.meta_gas_info) // We do this twice to make sure it gets in regardless of which order these are instantiated
			gas_singleton.meta_gas_list = GLOB.meta_gas_info[gas_path]
			GLOB.meta_gas_info[gas_path][META_GAS_COND_EVENT] = gas_singleton.cond_event

	if(SSair)
		SSair.gas_singletons = .

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
	/// A reference to the cached gas metadata list
	var/list/meta_gas_list

	/// A unique text id for this gas. Required to parse gas strings
	var/id = ""
	/// How much thermal energy is required to increase the temperature of one mole of this gas by 1 degree kelvin
	var/specific_heat = 0
	/// What this gas is referred to IC
	var/name = ""
	/// The icon state of the overlay used to indicate this gas's presence in the atmosphere
	var/gas_overlay = "" //icon_state in icons/effects/atmospherics.dmi
	/// How many moles are required before the gas overlay starts to show up. If null the gas is invisible
	var/moles_visible = null
	/// Whether or not the gas is dangerous. Used for logging
	var/dangerous = FALSE //currently used by canisters
	/// How much the gas accelerates a fusion reaction. See /code/modules/atmospherics/machinery/components/fusion/hypertorus.dm for details
	var/fusion_power = 0
	/// Relative rarity compared to other gases, used when setting up the reactions list.
	var/rarity = 0

	// Condensation:
	/// The maximum rate of condensation of this gas (as a function of total moles). If this is falsey the gas will not condense
	var/cond_rate
	/// The maximum temperature this gas will condense at
	var/cond_temp_max
	/// The temperature at and below which the gas will condense at it's maximum rate
	var/cond_temp_min
	/// The typepath of the reagent this gas condenses into. If this is null the reagents will not produce a gas when condensing
	var/datum/reagent/cond_type
	/// The amount of thermal energy released by one mole of this gas condensing
	var/cond_heat = 0
	/// A reference to the condensation event [CALLBACK] If this is truthy on init it will be repaced with the appropriate callback. Leave this as null
	var/datum/callback/cond_event = null

/datum/gas/New()
	. = ..()
	if(cond_event)
		cond_event = CALLBACK(src, .proc/on_condense)

/**
 * A proc used to generate the condensation event callback
 *
 * If the callback is generated this will be called whenever the gas condenses in a condenser
 *
 * Arguments:
 * - [holder][/datum/gas_mixture]: The gas mixture this is being condensed from
 * - cond_rate: The rate at which this is condensing in moles
 * - cond_temp: the temperature at which this is condensing in kelvin
 * - [location][/atom]: The atom this is condensing on or in
 * - [target][/datum/reagents]: The reagent mixture this gas is condensing to
 * - [cond_rates][/list]: The list of all condensation rates in the current condensation operation
 *   - Exists entirely in case someone wants to add a condensation effect that varies on simultaneous condensing gases
 *   - For the sake of avoiding race conditions this should be treated as read-only
 *   - NOTE: This does not actually contain the list of absolute condensation rates, only the list of relative condensation rates
 * - rate_multiplier: The multiplier to apply to the condensation rates
 * - delta_time: The amount of time the condensation is occuring over
 */
/datum/gas/proc/on_condense(datum/gas_mixture/holder, cond_moles, cond_temp, atom/location, datum/reagents/target, list/cond_rates, rate_multiplier, delta_time)
	return


/datum/gas/oxygen
	id = "o2"
	specific_heat = 20
	name = "Oxygen"
	rarity = 900
	cond_rate = 0.1
	cond_temp_max = 90
	cond_temp_min = TCMB
	cond_type = /datum/reagent/oxygen
	cond_heat = 6828

/datum/gas/nitrogen
	id = "n2"
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000
	cond_rate = 0.1
	cond_temp_max = 77
	cond_temp_min = TCMB
	cond_type = /datum/reagent/nitrogen
	cond_heat = 5590

/datum/gas/carbon_dioxide //what the fuck is this?
	id = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"
	rarity = 700
	cond_rate = 0.05
	cond_temp_max = BP_CARBON_DIOXIDE
	cond_temp_min = BP_CARBON_DIOXIDE
	cond_type = /datum/reagent/carbondioxide
	cond_heat = 25230

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 800
	cond_rate = 0.1
	cond_temp_max = BP_PLASMA
	cond_temp_min = TCMB
	cond_type = /datum/reagent/toxin/plasma
	cond_heat = 36000

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500
	cond_rate = 0.2
	cond_temp_max = BP_WATER
	cond_temp_min = T0C
	cond_type = /datum/reagent/water
	cond_heat = 40650

/datum/gas/hypernoblium
	id = "nob"
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 10
	rarity = 50

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	dangerous = TRUE
	rarity = 600
	cond_rate = 0.05
	cond_temp_max = BP_NITROUS_OXIDE
	cond_temp_min = BP_NITROUS_OXIDE - 3
	cond_type = /datum/reagent/nitrous_oxide
	cond_heat = 16560

/datum/gas/nitryl
	id = "no2"
	specific_heat = 20
	name = "Nitryl"
	gas_overlay = "nitryl"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 100

/datum/gas/tritium
	id = "tritium"
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 5
	rarity = 300
	cond_rate = 0.05
	cond_temp_max = BP_TRITIUM
	cond_temp_min = TCMB
	cond_type = /datum/reagent/hydrogen
	cond_event = TRUE
	cond_heat = 1390

/datum/gas/tritium/on_condense(datum/gas_mixture/holder, cond_moles, cond_temp, atom/location, datum/reagents/target, list/cond_rates)
	. = ..()
	if(cond_moles < TRITIUM_MINIMUM_RADIATION_ENERGY)
		return
	if(prob(50))
		radiation_pulse(location, cond_moles / TRITIUM_MINIMUM_RADIATION_ENERGY)

/datum/gas/bz
	id = "bz"
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8
	rarity = 400

/datum/gas/stimulum
	id = "stim"
	specific_heat = 5
	name = "Stimulum"
	fusion_power = 7
	rarity = 1

/datum/gas/pluoxium
	id = "pluox"
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	rarity = 200

/datum/gas/miasma
	id = "miasma"
	specific_heat = 20
	name = "Miasma"
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250

/datum/gas/freon
	id = "freon"
	specific_heat = 600
	name = "Freon"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE *30
	fusion_power = -5
	rarity = 10

/datum/gas/hydrogen
	id = "hydrogen"
	specific_heat = 15
	name = "Hydrogen"
	dangerous = TRUE
	fusion_power = 2
	rarity = 600
	cond_rate = 0.1
	cond_temp_max = BP_HYDROGEN
	cond_temp_min = TCMB
	cond_type = /datum/reagent/hydrogen
	cond_heat = 916

/datum/gas/healium
	id = "healium"
	specific_heat = 10
	name = "Healium"
	dangerous = TRUE
	gas_overlay = "healium"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300

/datum/gas/proto_nitrate
	id = "proto_nitrate"
	specific_heat = 30
	name = "Proto Nitrate"
	dangerous = TRUE
	gas_overlay = "proto_nitrate"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 200

/datum/gas/zauker
	id = "zauker"
	specific_heat = 350
	name = "Zauker"
	dangerous = TRUE
	gas_overlay = "zauker"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 1

/datum/gas/halon
	id = "halon"
	specific_heat = 175
	name = "Halon"
	dangerous = TRUE
	gas_overlay = "halon"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300

/datum/gas/helium
	id = "helium"
	specific_heat = 15
	name = "Helium"
	fusion_power = 7
	rarity = 50

/datum/gas/antinoblium
	id = "antinoblium"
	specific_heat = 1
	name = "Antinoblium"
	dangerous = TRUE
	gas_overlay = "antinoblium"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 20
	rarity = 1

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state, alph)
	. = ..()
	icon_state = state
	alpha = alph
