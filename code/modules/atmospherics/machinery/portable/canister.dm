///The default pressure for releasing air into an holding tank or the turf
#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)
///The temperature resistance of this canister
#define TEMPERATURE_RESISTANCE (1000 + T0C)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/machinery/portable_atmospherics/canister"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#6b6b80"
	density = TRUE
	volume = 2000
	armor_type = /datum/armor/portable_atmospherics_canister
	max_integrity = 300
	integrity_failure = 0.4
	pressure_resistance = 7 * ONE_ATMOSPHERE
	req_access = list()

	///Is the valve open?
	var/valve_open = FALSE
	///Used to log opening and closing of the valve, available on VV
	var/release_log = ""
	///How much the canister should be filled (recommended from 0 to 1)
	var/filled = 0.5
	///Maximum pressure allowed on initialize inside the canister, multiplied by the filled var
	var/maximum_pressure = 90 * ONE_ATMOSPHERE
	///Stores the path of the gas for mapped canisters
	var/datum/gas/gas_type
	///Player controlled var that set the release pressure of the canister
	var/release_pressure = ONE_ATMOSPHERE
	///Window overlay showing the gas inside the canister
	var/image/window
	///Is shielding turned on/off
	var/shielding_powered = FALSE
	///The powercell used to enable shielding
	var/obj/item/stock_parts/power_store/internal_cell
	///used while processing to update appearance only when its pressure state changes
	var/current_pressure_state

/datum/armor/portable_atmospherics_canister
	melee = 50
	bullet = 50
	laser = 50
	energy = 100
	bomb = 10
	fire = 80
	acid = 50

/obj/machinery/portable_atmospherics/canister/get_save_vars()
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	return .

/obj/machinery/portable_atmospherics/canister/Initialize(mapload)
	. = ..()

	if(mapload)
		internal_cell = new /obj/item/stock_parts/power_store/cell/high(src)

	if(!initial_gas_mix)
		create_gas()

	if(ispath(gas_type, /datum/gas))
		desc = "[GLOB.meta_gas_info[gas_type][META_GAS_NAME]]. [GLOB.meta_gas_info[gas_type][META_GAS_DESC]]"

	update_window()

	var/random_quality = rand()
	pressure_limit = initial(pressure_limit) * (1 + 0.2 * random_quality)

	update_appearance()
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/volatile_gas_storage)
	AddComponent(/datum/component/gas_leaker, leak_rate=0.01)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	. = ..()
	if(!allowed(user))
		to_chat(user, span_alert("Error - Unauthorized User."))
		playsound(src, 'sound/machines/compiler/compiler-failure.ogg', 50, TRUE)
		return

/obj/machinery/portable_atmospherics/canister/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(holding)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove tank"
	if(!held_item)
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stock_parts/power_store/cell))
		context[SCREENTIP_CONTEXT_LMB] = "Insert cell"
	switch(held_item.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] hatch"
		if(TOOL_CROWBAR)
			if(panel_open && internal_cell)
				context[SCREENTIP_CONTEXT_LMB] = "Remove cell"
		if(TOOL_WELDER)
			context[SCREENTIP_CONTEXT_LMB] = "Repair"
			context[SCREENTIP_CONTEXT_RMB] = "Dismantle"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/portable_atmospherics/canister/examine(user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_notice("Integrity compromised, repair hull with a welding tool.")
	. += span_notice("A sticker on its side says <b>MAX SAFE PRESSURE: [siunit_pressure(initial(pressure_limit), 0)]; MAX SAFE TEMPERATURE: [siunit(temp_limit, "K", 0)]</b>.")
	. += span_notice("The hull is <b>welded</b> together and can be cut apart.")
	if(internal_cell)
		. += span_notice("The internal cell has [internal_cell.percent()]% of its total charge.")
	else
		. += span_notice("Warning, no cell installed, use a screwdriver to open the hatch and insert one.")
	if(panel_open)
		. += span_notice("Hatch open, close it with a screwdriver.")

// Please keep the canister types sorted
// Basic canister per gas below here

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	icon_state = "/obj/machinery/portable_atmospherics/canister/air"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Antinoblium canister"
	gas_type = /datum/gas/antinoblium
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/antinoblium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#333333#fefb30"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	gas_type = /datum/gas/bz
	icon_state = "/obj/machinery/portable_atmospherics/canister/bz"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	gas_type = /datum/gas/carbon_dioxide
	icon_state = "/obj/machinery/portable_atmospherics/canister/carbon_dioxide"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4e4c48#eaeaea"

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	gas_type = /datum/gas/freon
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/freon"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6696ee#fefb30"

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	gas_type = /datum/gas/halon
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/halon"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	gas_type = /datum/gas/healium
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/healium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#ff0e00"

/obj/machinery/portable_atmospherics/canister/helium
	name = "Helium canister"
	gas_type = /datum/gas/helium
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/helium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	gas_type = /datum/gas/hydrogen
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/hydrogen"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#eaeaea#be3455"

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	gas_type = /datum/gas/miasma
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/miasma"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	gas_type = /datum/gas/nitrogen
	icon_state = "/obj/machinery/portable_atmospherics/canister/nitrogen"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#e9ff5c#f4fce8"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	gas_type = /datum/gas/nitrous_oxide
	icon_state = "/obj/machinery/portable_atmospherics/canister/nitrous_oxide"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	gas_type = /datum/gas/nitrium
	icon_state = "/obj/machinery/portable_atmospherics/canister/nitrium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	gas_type = /datum/gas/hypernoblium
	icon_state = "/obj/machinery/portable_atmospherics/canister/nob"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	gas_type = /datum/gas/oxygen
	icon_state = "/obj/machinery/portable_atmospherics/canister/oxygen"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	gas_type = /datum/gas/pluoxium
	icon_state = "/obj/machinery/portable_atmospherics/canister/pluoxium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/proto_nitrate
	name = "Proto Nitrate canister"
	gas_type = /datum/gas/proto_nitrate
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/proto_nitrate"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#008200#33cc33"

/obj/machinery/portable_atmospherics/canister/plasma
	name = "Plasma canister"
	gas_type = /datum/gas/plasma
	icon_state = "/obj/machinery/portable_atmospherics/canister/plasma"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f62800#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	gas_type = /datum/gas/tritium
	icon_state = "/obj/machinery/portable_atmospherics/canister/tritium"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	gas_type = /datum/gas/water_vapor
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/water_vapor"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	gas_type = /datum/gas/zauker
	filled = 1
	icon_state = "/obj/machinery/portable_atmospherics/canister/zauker"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009a00#006600"

// Special canisters below here

/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "fusion test canister"
	desc = "Don't be a badmin."
	temp_limit = 1e12
	pressure_limit = 1e14

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.add_gases(/datum/gas/hydrogen, /datum/gas/tritium)
	air_contents.gases[/datum/gas/hydrogen][MOLES] = 300
	air_contents.gases[/datum/gas/tritium][MOLES] = 300
	air_contents.temperature = 10000
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/anesthetic_mix
	name = "Anesthetic mix"
	desc = "A mixture of N2O and Oxygen"
	icon_state = "/obj/machinery/portable_atmospherics/canister/anesthetic_mix"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9fba6c#3d4680"

/obj/machinery/portable_atmospherics/canister/anesthetic_mix/create_gas()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (O2_ANESTHETIC * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (N2O_ANESTHETIC * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/**
 * Called on Initialize(), fill the canister with the gas_type specified up to the filled level (half if 0.5, full if 1)
 * Used for canisters spawned in maps and by admins
 */
/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(!gas_type)
		return
	air_contents.add_gas(gas_type)
	air_contents.gases[gas_type][MOLES] = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-1"
	return ..()

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()

	if(shielding_powered)
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', "shielding")
		. += emissive_appearance('icons/obj/pipes_n_cables/canisters.dmi', "shielding", src)

	if(panel_open)
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', "cell_hatch")

	///Function is used to actually set the overlays
	if(machine_stat & BROKEN)
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', "broken")
	if(holding)
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', "can-open")
	if(connected_port)
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', "can-connector")

	var/light_state = get_pressure_state()
	if(light_state) //happens when pressure is below 10kpa which means no light
		. += mutable_appearance('icons/obj/pipes_n_cables/canisters.dmi', light_state)
		. += emissive_appearance('icons/obj/pipes_n_cables/canisters.dmi', "[light_state]-light", src, alpha = src.alpha)

	update_window()

/obj/machinery/portable_atmospherics/canister/update_greyscale()
	. = ..()
	update_window()

///Updates the overlays of this canister based on its air contents
/obj/machinery/portable_atmospherics/canister/proc/update_window()
	if(!air_contents)
		return

	var/static/alpha_filter
	if(!alpha_filter) // Gotta do this separate since the icon may not be correct at world init
		alpha_filter = filter(type="alpha", icon = icon('icons/obj/pipes_n_cables/canisters.dmi', "window-base"))

	cut_overlay(window)
	window = image('icons/obj/pipes_n_cables/canisters.dmi', icon_state = "window-base", layer = FLOAT_LAYER)
	var/list/window_overlays = list()
	for(var/visual in air_contents.return_visuals(get_turf(src)))
		var/image/new_visual = image(visual, layer = FLOAT_LAYER)
		new_visual.filters = alpha_filter
		window_overlays += new_visual
	window.overlays = window_overlays
	add_overlay(window)

// Both of these procs handle the external temperature damage.
/obj/machinery/portable_atmospherics/canister/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > TEMPERATURE_RESISTANCE && !shielding_powered)

/obj/machinery/portable_atmospherics/canister/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/on_deconstruction(disassembled = TRUE)
	if(!(machine_stat & BROKEN))
		canister_break()
	if(!disassembled)
		new /obj/item/stack/sheet/iron (drop_location(), 5)
		qdel(src)
		return
	new /obj/item/stack/sheet/iron (drop_location(), 10)
	if(internal_cell)
		internal_cell.forceMove(drop_location())

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/stock_parts/power_store/cell))
		var/obj/item/stock_parts/power_store/cell/active_cell = item
		if(!panel_open)
			balloon_alert(user, "open hatch first!")
			return TRUE
		if(!user.transferItemToLoc(active_cell, src))
			return TRUE
		if(internal_cell)
			user.put_in_hands(internal_cell)
			balloon_alert(user, "you replace the cell")
		else
			balloon_alert(user, "you install the cell")
		internal_cell = active_cell
		return TRUE
	return ..()

/obj/machinery/portable_atmospherics/canister/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, screwdriver))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/portable_atmospherics/canister/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open || !internal_cell)
		return ITEM_INTERACT_BLOCKING

	internal_cell.forceMove(drop_location())
	balloon_alert(user, "cell removed")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/portable_atmospherics/canister/welder_act_secondary(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount=1, heat_required = HIGH_TEMPERATURE_REQUIRED))
		return ITEM_INTERACT_BLOCKING

	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, span_alert("The pressure gauge on [src] indicates a high pressure inside... maybe you want to reconsider?"))
		message_admins("[src] deconstructed by [ADMIN_LOOKUPFLW(user)]")
		user.log_message("deconstructed [src] with a welder.", LOG_GAME)
	to_chat(user, span_notice("You begin cutting [src] apart..."))
	if(I.use_tool(src, user, 3 SECONDS, volume=50))
		to_chat(user, span_notice("You cut [src] apart."))
		deconstruct(TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/machinery/portable_atmospherics/canister/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == internal_cell)
		internal_cell = null

/obj/machinery/portable_atmospherics/canister/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(!. || QDELETED(src))
		return
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

///Handle canisters disassemble, releases the gas content in the turf
/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)

	atom_break()

	set_density(FALSE)
	playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

	animate(src, 0.5 SECONDS, transform=turn(transform, rand(-179, 180)), easing=BOUNCE_EASING)

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return

	if(close_valve)
		valve_open = FALSE
		update_appearance()
		investigate_log("valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
	else if(valve_open && holding)
		user.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process(seconds_per_tick)
	if(!shielding_powered)
		return

	var/our_pressure = air_contents.return_pressure()
	var/our_temperature = air_contents.return_temperature()
	var/energy_factor = round(log(10, max(our_pressure - pressure_limit, 1)) + log(10, max(our_temperature - temp_limit, 1)))
	var/energy_consumed = energy_factor * 250 * seconds_per_tick

	if(!energy_consumed)
		return

	if(powered(AREA_USAGE_EQUIP, ignore_use_power = TRUE))
		use_energy(energy_consumed, channel = AREA_USAGE_EQUIP)
	else if(!internal_cell?.use(energy_consumed * 0.025))
		shielding_powered = FALSE
		SSair.start_processing_machine(src)
		investigate_log("shielding turned off due to power loss")
		update_appearance()

///return the icon_state component for the canister's indicator light based on its current pressure reading
/obj/machinery/portable_atmospherics/canister/proc/get_pressure_state()
	var/air_pressure = air_contents.return_pressure()
	switch(air_pressure)
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			return "can-3"
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			return "can-2"
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			return "can-1"
		if((10) to (5 * ONE_ATMOSPHERE))
			return "can-0"
		else
			return null

/obj/machinery/portable_atmospherics/canister/process_atmos()
	if(machine_stat & BROKEN)
		return PROCESS_KILL

	// Handle gas transfer.
	if(valve_open)
		var/turf/location = get_turf(src)
		var/datum/gas_mixture/target_air = holding?.return_air() || location.return_air()
		excited = TRUE

		if(air_contents.release_gas_to(target_air, release_pressure))
			if(!holding)
				air_update_turf(FALSE, FALSE)

	// A bit different than other atmos devices. Wont stop if currently taking damage.
	if(take_atmos_damage())
		update_appearance()
		excited = TRUE
		return ..() //we have already updated appearance so dont need to update again below

	var/new_pressure_state = get_pressure_state()
	if(current_pressure_state != new_pressure_state) //update apperance only when its pressure changes significantly from its current value
		update_appearance()
		current_pressure_state = new_pressure_state

	return ..()

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	return list(
		"defaultReleasePressure" = round(CAN_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(CAN_MIN_RELEASE_PRESSURE),
		"maxReleasePressure" = round(CAN_MAX_RELEASE_PRESSURE),
		"pressureLimit" = round(pressure_limit),
		"holdingTankLeakPressure" = round(TANK_LEAK_PRESSURE),
		"holdingTankFragPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/machinery/portable_atmospherics/canister/ui_data()
	. = list(
		"portConnected" = !!connected_port,
		"tankPressure" = round(air_contents.return_pressure()),
		"releasePressure" = round(release_pressure),
		"valveOpen" = !!valve_open,
		"hasHoldingTank" = !!holding,
		"hasHypernobCrystal" = !!nob_crystal_inserted,
		"reactionSuppressionEnabled" = !!suppress_reactions
	)

	if (holding)
		var/datum/gas_mixture/holding_mix = holding.return_air()
		.["holdingTank"] = list(
			"name" = holding.name,
			"tankPressure" = round(holding_mix.return_pressure())
		)
	else
		.["holdingTank"] = null

	. += list(
		"shielding" = shielding_powered,
		"cellCharge" = internal_cell ? internal_cell.percent() : 0
	)

/obj/machinery/portable_atmospherics/canister/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("relabel")
			var/label = tgui_input_list(usr, "New canister label", "Canister", GLOB.gas_id_to_canister)
			if(isnull(label))
				return
			var/newtype = GLOB.gas_id_to_canister[label]
			if(isnull(newtype))
				return
			var/obj/machinery/portable_atmospherics/canister/replacement = newtype
			investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
			name = initial(replacement.name)
			desc = initial(replacement.desc)
			icon_state = initial(replacement.icon_state)
			base_icon_state = icon_state
			set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))

		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = CAN_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = CAN_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = tgui_input_number(usr, message = "New release pressure", title = "Canister Pressure", default = release_pressure, max_value = CAN_MAX_RELEASE_PRESSURE, min_value = CAN_MIN_RELEASE_PRESSURE, round_value = FALSE)
				if(!isnull(pressure))
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(pressure, CAN_MIN_RELEASE_PRESSURE, CAN_MAX_RELEASE_PRESSURE)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)

		if("valve")
			toggle_valve(usr)
			. = TRUE

		if("eject")
			if(eject_tank(usr))
				. = TRUE

		if("shielding")
			toggle_shielding(usr)
			. = TRUE

		if("reaction_suppression")
			toggle_reaction_suppression(usr)
			. = TRUE

		if("recolor")
			var/initial_config = initial(greyscale_config)
			if(isnull(initial_config))
				return FALSE

			var/datum/greyscale_modify_menu/menu = new(
				src, usr, list("[initial_config]"), CALLBACK(src, PROC_REF(recolor)),
				starting_icon_state = initial(post_init_icon_state) || initial(icon_state),
				starting_config = initial_config,
				starting_colors = initial(greyscale_colors)
			)
			menu.ui_interact(usr)
			. = TRUE

	update_appearance()

/// Opens/closes the canister valve
/obj/machinery/portable_atmospherics/canister/proc/toggle_valve(mob/user, wire_pulsed = FALSE)
	valve_open = !valve_open
	if(!valve_open)
		var/logmsg = "valve was <b>closed</b> by [key_name(user)] [wire_pulsed ? "via wire pulse" : ""], stopping the transfer into \the [holding || "air"].<br>"
		investigate_log(logmsg, INVESTIGATE_ATMOS)
		release_log += logmsg
		return

	SSair.start_processing_machine(src)
	if(holding)
		var/logmsg = "Valve was <b>opened</b> by [key_name(user)] [wire_pulsed ? "via wire pulse" : ""], starting a transfer into \the [holding || "air"].<br>"
		investigate_log(logmsg, INVESTIGATE_ATMOS)
		release_log += logmsg
		return

	// Go over the gases in canister, pull all their info and mark the spooky ones
	var/list/output = list()
	output += "[key_name(user)] <b>opened</b> a canister [wire_pulsed ? "via wire pulse" : ""] that contains the following:"
	var/list/admin_output = list()
	admin_output += "[ADMIN_LOOKUPFLW(user)] <b>opened</b> a canister [wire_pulsed ? "via wire pulse" : ""] that contains the following at [ADMIN_VERBOSEJMP(src)]:"
	var/list/gases = air_contents.gases
	var/danger = FALSE
	for(var/gas_index in 1 to length(gases))
		var/list/gas_info = gases[gases[gas_index]]
		var/list/meta = gas_info[GAS_META]
		var/name = meta[META_GAS_NAME]
		var/moles = gas_info[MOLES]

		output += "[name]: [moles] moles."
		if(gas_index <= 5) //the first five gases added
			admin_output += "[name]: [moles] moles."
		else if(gas_index == 6) // anddd the warning
			admin_output += "Too many gases to log. Check investigate log."
		//if moles_visible is undefined, default to default visibility
		if(meta[META_GAS_DANGER] && moles > (meta[META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE))
			danger = TRUE

	if(danger) //sent to admin's chat if contains dangerous gases
		message_admins(admin_output.Join("\n"))
	var/logmsg = output.Join("\n")
	investigate_log(logmsg, INVESTIGATE_ATMOS)
	release_log += logmsg

/// Turns canister shielding on or off
/obj/machinery/portable_atmospherics/canister/proc/toggle_shielding(mob/user, wire_pulsed = FALSE)
	shielding_powered = !shielding_powered
	SSair.start_processing_machine(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] turned [shielding_powered ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] powered shielding.")
	user.investigate_log("turned [shielding_powered ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] powered shielding.", INVESTIGATE_ATMOS)
	update_appearance()

/// Ejects tank from canister, if any
/obj/machinery/portable_atmospherics/canister/proc/eject_tank(mob/user, wire_pulsed = FALSE)
	if(!holding)
		return FALSE
	if(valve_open)
		message_admins("[ADMIN_LOOKUPFLW(user)] removed [holding] from [src] with valve still open [wire_pulsed ? "via wire pulse" : ""] at [ADMIN_VERBOSEJMP(src)] releasing contents into the [span_bolddanger("air")].")
		user.investigate_log("removed the [holding] [wire_pulsed ? "via wire pulse" : ""], leaving the valve open and transferring into the [span_bolddanger("air")].", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE)
	return TRUE

/// Turns hyper-noblium crystal reaction suppression in the canister on or off
/obj/machinery/portable_atmospherics/canister/proc/toggle_reaction_suppression(mob/user, wire_pulsed = FALSE)
	if(!nob_crystal_inserted)
		if(!wire_pulsed)
			stack_trace("[user] tried to toggle reaction suppression on a canister without a noblium crystal inside and without pulsing wires, possible href exploit attempt.")
		return
	suppress_reactions = !suppress_reactions
	SSair.start_processing_machine(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] turned [suppress_reactions ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] reaction suppression.")
	user.investigate_log("turned [suppress_reactions ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] reaction suppression.", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/proc/recolor(datum/greyscale_modify_menu/menu)
	set_greyscale(menu.split_colors, menu.config.type)

/obj/machinery/portable_atmospherics/canister/unregister_holding()
	valve_open = FALSE
	return ..()

/obj/machinery/portable_atmospherics/canister/take_atmos_damage()
	return shielding_powered ? FALSE : ..()

#undef CAN_DEFAULT_RELEASE_PRESSURE
#undef TEMPERATURE_RESISTANCE
