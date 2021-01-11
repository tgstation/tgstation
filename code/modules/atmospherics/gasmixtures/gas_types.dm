GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
//Now this is what I call history
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/stimulum, /datum/gas/nitryl))) //unable to react amongst themselves

/// Constructs the global list of gas singletons
/proc/init_gas_singletons()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas_singleton = new gas_path
		.[gas_path] = gas_singleton

/// Constructs the global cache of relevant gas data. Requries that [GLOB.gas_singletons] exists
/proc/init_meta_gas_list()
	. = subtypesof(/datum/gas)
	var/list/cached_gases = GLOB.gas_singletons
	for(var/gas_path in .)
		var/datum/gas/gas_singleton = cached_gases[gas_path]
		.[gas_path] = gas_singleton.meta_gas_list

/// Helper that converts a gas's id to a gas's path
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
	init_metadata_cache()

/**
 * Initializes the gas metadata list.
 */
/datum/gas/proc/init_metadata_cache()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)

	. = meta_gas_list = new /list(META_GAS_LEN)
	.[META_GAS_SPECIFIC_HEAT] = specific_heat
	.[META_GAS_NAME] = name

	.[META_GAS_MOLES_VISIBLE] = moles_visible
	if(moles_visible != null)
		.[META_GAS_OVERLAY] = init_gas_overlays()

	.[META_GAS_FUSION_POWER] = fusion_power
	.[META_GAS_DANGER] = dangerous
	.[META_GAS_ID] = id

	.[META_GAS_COND_RATE] = cond_rate
	.[META_GAS_COND_TEMP_MAX] = cond_temp_max
	.[META_GAS_COND_TEMP_MIN] = cond_temp_min
	.[META_GAS_COND_TYPE] = cond_type
	.[META_GAS_COND_HEAT] = cond_heat

	if(cond_event != null)
		.[META_GAS_COND_EVENT] = init_cond_event()

/// Initializes the overlays used to represent this gas in the air. Not inlined in case we want a gas to have special visual effects (ie: emissive gas overlays)
/datum/gas/proc/init_gas_overlays()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)

	. = new /list(TOTAL_VISIBLE_STATES)
	var/cached_overlay_state = gas_overlay
	for(var/i in 1 to TOTAL_VISIBLE_STATES)
		var/overlay_alpha = 255 * log(4, (i + (0.4*TOTAL_VISIBLE_STATES)) / (0.35*TOTAL_VISIBLE_STATES))
		.[i] = new /obj/effect/overlay/gas(cached_overlay_state, overlay_alpha)

/// Initializes the condensation event callback
/datum/gas/proc/init_cond_event()
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)

	cond_event = CALLBACK(src, .proc/on_condense)
	return cond_event

/// Updates the meta_gas_list in sync with the gas's vars
/datum/gas/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return

	switch(var_name)
		if(NAMEOF(src, name))
			meta_gas_list[META_GAS_NAME] = var_value
		if(NAMEOF(src, id))
			meta_gas_list[META_GAS_ID] = var_value

		if(NAMEOF(src, moles_visible))
			var/old_value = meta_gas_list[META_GAS_MOLES_VISIBLE]
			meta_gas_list[META_GAS_MOLES_VISIBLE] = var_value
			if(var_value && gas_overlay)
				if(!old_value)
					meta_gas_list[META_GAS_OVERLAY] = init_gas_overlays()
			else
				meta_gas_list[META_GAS_OVERLAY] = null
		if(NAMEOF(src, gas_overlay))
			var/old_value = meta_gas_list[META_GAS_OVERLAY]
			if(var_value && moles_visible)
				if(var_value != old_value)
					meta_gas_list[META_GAS_OVERLAY] = init_gas_overlays()
			else
				meta_gas_list[META_GAS_OVERLAY] = null

		if(NAMEOF(src, dangerous))
			meta_gas_list[META_GAS_DANGER] = var_value

		if(NAMEOF(src, specific_heat))
			meta_gas_list[META_GAS_SPECIFIC_HEAT] = var_value
		if(NAMEOF(src, fusion_power))
			meta_gas_list[META_GAS_FUSION_POWER] = var_value

		if(NAMEOF(src, cond_rate))
			meta_gas_list[META_GAS_COND_RATE] = var_value
		if(NAMEOF(src, cond_temp_max))
			meta_gas_list[META_GAS_COND_TEMP_MAX] = var_value
		if(NAMEOF(src, cond_temp_min))
			meta_gas_list[META_GAS_COND_TEMP_MIN] = var_value
		if(NAMEOF(src, cond_type))
			meta_gas_list[META_GAS_COND_TYPE] = var_value
		if(NAMEOF(src, cond_heat))
			meta_gas_list[META_GAS_COND_HEAT] = var_value
		if(NAMEOF(src, cond_event))
			if(!(isnull(var_value) || istype(var_value, /datum/callback)))
				var_value = initial(cond_event) ? init_cond_event() : null
			meta_gas_list[META_GAS_COND_EVENT] = var_value

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
	SHOULD_NOT_SLEEP(TRUE)
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
