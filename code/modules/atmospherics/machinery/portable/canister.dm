#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

///List of all the gases, used in labelling the canisters
GLOBAL_LIST_INIT(gas_id_to_canister, init_gas_id_to_canister())

/proc/init_gas_id_to_canister()
	return sort_list(list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/plasma,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"nitrium" = /obj/machinery/portable_atmospherics/canister/nitrium,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"water_vapor" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tritium" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hyper-noblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"pluoxium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"caution" = /obj/machinery/portable_atmospherics/canister,
		"miasma" = /obj/machinery/portable_atmospherics/canister/miasma,
		"freon" = /obj/machinery/portable_atmospherics/canister/freon,
		"hydrogen" = /obj/machinery/portable_atmospherics/canister/hydrogen,
		"healium" = /obj/machinery/portable_atmospherics/canister/healium,
		"proto_nitrate" = /obj/machinery/portable_atmospherics/canister/proto_nitrate,
		"zauker" = /obj/machinery/portable_atmospherics/canister/zauker,
		"helium" = /obj/machinery/portable_atmospherics/canister/helium,
		"antinoblium" = /obj/machinery/portable_atmospherics/canister/antinoblium,
		"halon" = /obj/machinery/portable_atmospherics/canister/halon
	))

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmospherics/canisters.dmi'
	icon_state = "#mapme"
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
	volume = 2000
	armor_type = /datum/armor/portable_atmospherics_canister
	max_integrity = 300
	integrity_failure = 0.4
	pressure_resistance = 7 * ONE_ATMOSPHERE
	req_access = list()

	var/icon/canister_overlay_file = 'icons/obj/atmospherics/canisters.dmi'

	///Is the valve open?
	var/valve_open = FALSE
	///Used to log opening and closing of the valve, available on VV
	var/release_log = ""
	///How much the canister should be filled (recommended from 0 to 1)
	var/filled = 0.5
	///Maximum pressure allowed on initialize inside the canister, multiplied by the filled var
	var/maximum_pressure = 90 * ONE_ATMOSPHERE
	///Stores the path of the gas for mapped canisters
	var/gas_type
	///Player controlled var that set the release pressure of the canister
	var/release_pressure = ONE_ATMOSPHERE
	///Maximum pressure allowed for release_pressure var
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 25)
	///Minimum pressure allower for release_pressure var
	var/can_min_release_pressure = (ONE_ATMOSPHERE * 0.1)
	///Maximum amount of external heat that the canister can handle before taking damage
	var/temperature_resistance = 1000 + T0C
	///Initial temperature gas mixture
	var/starter_temp
	// Prototype vars
	///Is the canister a prototype one?
	var/prototype = FALSE
	///Timer variables
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	///If true, the prototype canister requires engi access to be used
	var/restricted = FALSE
	///Window overlay showing the gas inside the canister
	var/image/window

	var/shielding_powered = FALSE

	var/obj/item/stock_parts/cell/internal_cell

	var/cell_container_opened = FALSE

	var/protected_contents = FALSE

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

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()

	if(mapload)
		internal_cell = new /obj/item/stock_parts/cell/high(src)

	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
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
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, TRUE)
		return

/obj/machinery/portable_atmospherics/canister/examine(user)
	. = ..()
	. += span_notice("A sticker on its side says <b>MAX SAFE PRESSURE: [siunit_pressure(initial(pressure_limit), 0)]; MAX SAFE TEMPERATURE: [siunit(temp_limit, "K", 0)]</b>.")
	if(internal_cell)
		. += span_notice("The internal cell has [internal_cell.percent()]% of its total charge.")
	else
		. += span_notice("Warning, no cell installed, use a screwdriver to open the hatch and insert one.")
	if(cell_container_opened)
		. += span_notice("Cell hatch open, close it with a screwdriver.")

// Please keep the canister types sorted
// Basic canister per gas below here

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Antinoblium canister"
	gas_type = /datum/gas/antinoblium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	gas_type = /datum/gas/bz
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	gas_type = /datum/gas/carbon_dioxide
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	gas_type = /datum/gas/freon
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6696ee#fefb30"

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	gas_type = /datum/gas/halon
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	gas_type = /datum/gas/healium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#ff0e00"

/obj/machinery/portable_atmospherics/canister/helium
	name = "Helium canister"
	gas_type = /datum/gas/helium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	gas_type = /datum/gas/hydrogen
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#bdc2c0#ffffff"

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	gas_type = /datum/gas/miasma
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	gas_type = /datum/gas/nitrogen
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	gas_type = /datum/gas/nitrous_oxide
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	gas_type = /datum/gas/nitrium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	gas_type = /datum/gas/hypernoblium
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	gas_type = /datum/gas/oxygen
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	gas_type = /datum/gas/pluoxium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/proto_nitrate
	name = "Proto Nitrate canister"
	gas_type = /datum/gas/proto_nitrate
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#008200#33cc33"

/obj/machinery/portable_atmospherics/canister/plasma
	name = "Plasma canister"
	gas_type = /datum/gas/plasma
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f62800#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	gas_type = /datum/gas/tritium
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	gas_type = /datum/gas/water_vapor
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	gas_type = /datum/gas/zauker
	filled = 1
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
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9fba6c#3d4680"

/obj/machinery/portable_atmospherics/canister/anesthetic_mix/create_gas()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (O2_ANESTHETIC * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (N2O_ANESTHETIC * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/**
 * Getter for the amount of time left in the timer of prototype canisters
 */
/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) * 0.1, 1)
	else
		. = timer_set

/**
 * Starts the timer of prototype canisters
 */
/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set SECONDS)
	update_appearance()

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototype canister"
	greyscale_config = /datum/greyscale_config/prototype_canister
	greyscale_colors = "#ffffff#a50021#ffffff"

/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototype canister"
	desc = "The best way to fix an atmospheric emergency... or the best way to introduce one."
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE

/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototype canister"
	desc = "A prototype canister for a prototype bike, what could go wrong?"
	gas_type = /datum/gas/oxygen
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/**
 * Called on Initialize(), fill the canister with the gas_type specified up to the filled level (half if 0.5, full if 1)
 * Used for canisters spawned in maps and by admins
 */
/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(!gas_type)
		return
	air_contents.add_gas(gas_type)
	if(starter_temp)
		air_contents.temperature = starter_temp
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
		. += mutable_appearance(canister_overlay_file, "shielding")
		. += emissive_appearance(canister_overlay_file, "shielding", src)

	if(cell_container_opened)
		. += mutable_appearance(canister_overlay_file, "cell_hatch")

	var/isBroken = machine_stat & BROKEN
	///Function is used to actually set the overlays
	if(isBroken)
		. += mutable_appearance(canister_overlay_file, "broken")
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")

	var/light_state = get_pressure_state(air_contents.return_pressure())
	if(light_state) //happens when pressure is below 10kpa which means no light
		. += mutable_appearance(canister_overlay_file, light_state)
		. += emissive_appearance(canister_overlay_file, "[light_state]-light", src, alpha = src.alpha)

	update_window()

/obj/machinery/portable_atmospherics/canister/update_greyscale()
	. = ..()
	update_window()

/obj/machinery/portable_atmospherics/canister/proc/update_window()
	if(!air_contents)
		return
	var/static/alpha_filter
	if(!alpha_filter) // Gotta do this separate since the icon may not be correct at world init
		alpha_filter = filter(type="alpha", icon=icon(icon, "window-base"))

	cut_overlay(window)
	window = image(icon, icon_state="window-base", layer=FLOAT_LAYER)
	var/list/window_overlays = list()
	for(var/visual in air_contents.return_visuals(get_turf(src)))
		var/image/new_visual = image(visual, layer=FLOAT_LAYER)
		new_visual.filters = alpha_filter
		window_overlays += new_visual
	window.overlays = window_overlays
	add_overlay(window)

// Both of these procs handle the external temperature damage.
/obj/machinery/portable_atmospherics/canister/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > temperature_resistance && !shielding_powered)

/obj/machinery/portable_atmospherics/canister/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if((flags_1 & NODECONSTRUCT_1))
		return
	if(!(machine_stat & BROKEN))
		canister_break()
	if(!disassembled)
		new /obj/item/stack/sheet/iron (drop_location(), 5)
		qdel(src)
		return
	new /obj/item/stack/sheet/iron (drop_location(), 10)
	if(internal_cell)
		internal_cell.forceMove(drop_location())
	qdel(src)

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/active_cell = item
		if(!cell_container_opened)
			balloon_alert(user, "open the hatch first")
			return
		if(!user.transferItemToLoc(active_cell, src))
			return
		if(internal_cell)
			user.put_in_hands(internal_cell)
			balloon_alert(user, "you successfully replace the cell")
		else
			balloon_alert(user, "you successfully install the cell")
		internal_cell = active_cell
		return
	return ..()

/obj/machinery/portable_atmospherics/canister/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(screwdriver.tool_behaviour != TOOL_SCREWDRIVER)
		return
	screwdriver.play_tool_sound(src, 50)
	cell_container_opened = !cell_container_opened
	to_chat(user, span_notice("You [cell_container_opened ? "open" : "close"] the cell container hatch of [src]."))
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/canister/crowbar_act(mob/living/user, obj/item/tool)
	if(!cell_container_opened || !internal_cell)
		return
	internal_cell.forceMove(drop_location())
	balloon_alert(user, "you successfully remove the cell")
	return TRUE

/obj/machinery/portable_atmospherics/canister/welder_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, span_alert("The pressure gauge on [src] indicates a high pressure inside... maybe you want to reconsider?"))
		message_admins("[src] deconstructed by [ADMIN_LOOKUPFLW(user)]")
		user.log_message("deconstructed [src] with a welder.", LOG_GAME)
	to_chat(user, span_notice("You begin cutting [src] apart..."))
	if(I.use_tool(src, user, 3 SECONDS, volume=50))
		to_chat(user, span_notice("You cut [src] apart."))
		deconstruct(TRUE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity >= max_integrity)
		return TRUE
	if(machine_stat & BROKEN)
		return TRUE
	if(!tool.tool_start_check(user, amount=0))
		return TRUE
	to_chat(user, span_notice("You begin repairing cracks in [src]..."))
	while(tool.use_tool(src, user, 2.5 SECONDS, volume=40))
		atom_integrity = min(atom_integrity + 25, max_integrity)
		if(atom_integrity >= max_integrity)
			to_chat(user, span_notice("You've finished repairing [src]."))
			return TRUE
		to_chat(user, span_notice("You repair some of the cracks in [src]..."))
	return TRUE

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

/**
 * Handle canisters disassemble, releases the gas content in the turf
 */
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

/obj/machinery/portable_atmospherics/canister/process(delta_time)

	var/our_pressure = air_contents.return_pressure()
	var/our_temperature = air_contents.return_temperature()

	protected_contents = FALSE
	if(shielding_powered)
		var/power_factor = round(log(10, max(our_pressure - pressure_limit, 1)) + log(10, max(our_temperature - temp_limit, 1)))
		var/power_consumed = power_factor * 250 * delta_time
		if(powered(AREA_USAGE_EQUIP, ignore_use_power = TRUE))
			use_power(power_consumed, AREA_USAGE_EQUIP)
			protected_contents = TRUE
		else if(internal_cell?.use(power_consumed * 0.025))
			protected_contents = TRUE
		else
			shielding_powered = FALSE
			SSair.start_processing_machine(src)
			investigate_log("shielding turned off due to power loss")

///return the icon_state component for the canister's indicator light based on its current pressure reading
/obj/machinery/portable_atmospherics/canister/proc/get_pressure_state(air_pressure)
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
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE

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

	var/new_pressure_state = get_pressure_state(air_contents.return_pressure())
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
		"minReleasePressure" = round(can_min_release_pressure),
		"maxReleasePressure" = round(can_max_release_pressure),
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
		"isPrototype" = !!prototype,
		"hasHoldingTank" = !!holding,
		"hasHypernobCrystal" = !!nob_crystal_inserted,
		"reactionSuppressionEnabled" = !!suppress_reactions
	)

	if (prototype)
		. += list(
			"restricted" = restricted,
			"timing" = timing,
			"time_left" = get_time_left(),
			"timer_set" = timer_set,
			"timer_is_not_default" = timer_set != default_timer_set,
			"timer_is_not_min" = timer_set != minimum_timer_set,
			"timer_is_not_max" = timer_set != maximum_timer_set
		)

	if (holding)
		var/datum/gas_mixture/holding_mix = holding.return_air()
		. += list(
			"holdingTank" = list(
				"name" = holding.name,
				"tankPressure" = round(holding_mix.return_pressure())
			)
		)
	. += list(
		"shielding" = shielding_powered,
		"hasCell" = (internal_cell ? TRUE : FALSE),
		"cellCharge" = internal_cell?.percent()
	)

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("relabel")
			var/label = tgui_input_list(usr, "New canister label", "Canister", GLOB.gas_id_to_canister)
			if(isnull(label))
				return
			if(!..())
				var/newtype = GLOB.gas_id_to_canister[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
					base_icon_state = icon_state
					set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
		if("restricted")
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINEERING)
			else
				req_access = list()
				. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = tgui_input_number(usr, "New release pressure", "Canister Pressure", release_pressure, can_max_release_pressure, can_min_release_pressure)
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")		//logging for openning canisters
			var/logmsg
			var/admin_msg
			var/danger = FALSE
			var/n = 0
			valve_open = !valve_open
			if(valve_open)
				SSair.start_processing_machine(src)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				if(!holding)
					var/list/gaseslog = list() //list for logging all gases in canister
					for(var/id in air_contents.gases)
						var/gas = air_contents.gases[id]
						gaseslog[gas[GAS_META][META_GAS_NAME]] = gas[MOLES]	//adds gases to gaseslog
						if(!gas[GAS_META][META_GAS_DANGER])
							continue
						if(gas[MOLES] > (gas[GAS_META][META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger = TRUE //at least 1 danger gas
					logmsg = "[key_name(usr)] <b>opened</b> a canister that contains the following:"
					admin_msg = "[ADMIN_LOOKUPFLW(usr)] <b>opened</b> a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:"
					for(var/name in gaseslog)
						n = n + 1
						logmsg += "\n[name]: [gaseslog[name]] moles."
						if(n <= 5) //the first five gases added
							admin_msg += "\n[name]: [gaseslog[name]] moles."
						if(n == 5 && length(gaseslog) > 5) //message added if more than 5 gases
							admin_msg += "\nToo many gases to log. Check investigate log."
					if(danger) //sent to admin's chat if contains dangerous gases
						message_admins(admin_msg)
			else
				logmsg = "valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
			investigate_log(logmsg, INVESTIGATE_ATMOS)
			release_log += logmsg
			. = TRUE
		if("timer")
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				if("input")
					var/user_input = tgui_input_number(usr, "Set time to valve toggle", "Canister Timer", timer_set, maximum_timer_set, minimum_timer_set)
					if(isnull(user_input) || QDELETED(usr) || QDELETED(src) || !usr.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
						return
					timer_set = user_input
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the [span_boldannounce("air")].")
					usr.investigate_log("removed the [holding], leaving the valve open and transferring into the [span_boldannounce("air")].", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE

		if("shielding")
			shielding_powered = !shielding_powered
			SSair.start_processing_machine(src)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [shielding_powered ? "on" : "off"] the [src] powered shielding.")
			usr.investigate_log("turned [shielding_powered ? "on" : "off"] the [src] powered shielding.")
			. = TRUE
		if("reaction_suppression")
			if(!nob_crystal_inserted)
				stack_trace("[usr] tried to toggle reaction suppression on a canister without a noblium crystal inside, possible href exploit attempt.")
				return
			suppress_reactions = !suppress_reactions
			SSair.start_processing_machine(src)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			usr.investigate_log("turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			. = TRUE

	update_appearance()

/obj/machinery/portable_atmospherics/canister/unregister_holding()
	valve_open = FALSE
	return ..()

/obj/machinery/portable_atmospherics/canister/take_atmos_damage()
	if(shielding_powered)
		return FALSE
	return ..()
