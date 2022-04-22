GLOBAL_REAL(xgm_gas_data, /datum/xgm_gas_data) = new
/datum/xgm_gas_data
	//Simple list of all the gas IDs.
	var/list/gases = list()
	//The friendly, human-readable name for the gas.
	var/list/name = list()
	//Specific heat of the gas.  Used for calculating heat capacity.
	var/list/specific_heat = list()
	//Molar mass of the gas.  Used for calculating specific entropy.
	var/list/molar_mass = list()
	//Tile overlays.  /obj/effect/gas_overlay, created from references to 'icons/effects/tile_effects.dmi'
	var/list/tile_overlay = list()
	//Optional color for tile overlay
	var/list/tile_overlay_color = list()
	//Overlay limits.  There must be at least this many moles for the overlay to appear.
	var/list/overlay_limit = list()
	//Flags.
	var/list/flags = list()
	//Products created when burned. For fuel only for now (not oxidizers)
	var/list/burn_product = list()
	// Reagent created when inhaled by lungs.
	var/list/breathed_product = list()
	// Temperature in K that the gas will condense.
	var/list/condensation_points = list()
	// Reagent path resulting from condesation.
	var/list/condensation_products = list()
	//If it shouldn't autogenerate a codex entry
	var/list/hidden_from_codex = list()

	//Holds the symbols
	var/list/symbol_html = list()
	var/list/symbol = list()

	//Base sell values
	var/list/base_value = list()
	//Purchasable?
	var/list/purchaseable = list()

/datum/xgm_gas
	var/id = ""
	var/name = "Unnamed Gas"
	var/specific_heat = 20	// J/(mol*K)
	var/molar_mass = 0.032	// kg/mol

	var/tile_overlay = "generic"
	var/tile_color = null
	var/overlay_limit = null

	var/flags = 0
	var/burn_product = GAS_CO2
	var/breathed_product
	var/condensation_point = INFINITY
	var/condensation_product
	var/hidden_from_codex
	var/symbol_html = "X"
	var/symbol = "X"
	var/base_value = 1
	var/purchaseable = FALSE

/datum/xgm_gas_data/New()
	for(var/p in subtypesof(/datum/xgm_gas))
		var/datum/xgm_gas/gas = new p //avoid initial() because of potential New() actions

		//if(gas.id in xgm_gas_data.gases)
			//stack_trace("Duplicate gas id `[gas.id]` in `[p]`")

		gases += gas.id
		name[gas.id] = gas.name
		specific_heat[gas.id] = gas.specific_heat
		molar_mass[gas.id] = gas.molar_mass
		if(gas.overlay_limit)
			overlay_limit[gas.id] = gas.overlay_limit
			tile_overlay[gas.id] = gas.tile_overlay
			tile_overlay_color[gas.id] = gas.tile_color
		flags[gas.id] = gas.flags
		burn_product[gas.id] = gas.burn_product

		symbol_html[gas.id] = gas.symbol_html
		symbol[gas.id] = gas.symbol

		if(!isnull(gas.condensation_product) && !isnull(gas.condensation_point))
			condensation_points[gas.id] = gas.condensation_point
			condensation_products[gas.id] = gas.condensation_product

		breathed_product[gas.id] = gas.breathed_product
		hidden_from_codex[gas.id] = gas.hidden_from_codex

		base_value[gas.id] = gas.base_value
		purchaseable[gas.id] = gas.purchaseable

	return 1

/obj/effect/gas_overlay
	name = "gas"
	desc = "You shouldn't be clicking this."
	icon = 'modular_pariah/master_files/icons/effects/gas_overlays.dmi'
	icon_state = "generic"
	layer = GAS_LAYER
	plane = ABOVE_GAME_PLANE
	appearance_flags = RESET_COLOR|PIXEL_SCALE|TILE_BOUND
	mouse_opacity = 0
	vis_flags = NONE
	var/gas_id

/obj/effect/gas_overlay/proc/update_alpha_animation(var/new_alpha)
	animate(src, alpha = new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0.8 * new_alpha, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = new_alpha, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/obj/effect/gas_overlay/Initialize(mapload, gas)
	. = ..()
	gas_id = gas
	if(xgm_gas_data.tile_overlay[gas_id])
		icon_state = xgm_gas_data.tile_overlay[gas_id]
	color = xgm_gas_data.tile_overlay_color[gas_id]

/proc/typecache_of_gases_with_no_overlays()
	. = list()
	for (var/gastype in subtypesof(/datum/xgm_gas))
		var/datum/xgm_gas/gasvar = gastype
		if (!initial(gasvar.tile_overlay))
			.[gastype] = TRUE
