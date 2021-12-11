#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)
///Used when setting the mode of the canisters, enabling us to switch the overlays
//These are used as icon states later down the line for tier overlays
#define CANISTER_TIER_1 1
#define CANISTER_TIER_2 2
#define CANISTER_TIER_3 3

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
	volume = 1000
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, BIO = 100, FIRE = 80, ACID = 50)
	max_integrity = 250
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
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	///Minimum pressure allower for release_pressure var
	var/can_min_release_pressure = (ONE_ATMOSPHERE * 0.1)
	///Max amount of heat allowed inside of the canister before it starts to melt (different tiers have different limits)
	var/heat_limit = 5000
	///Max amount of pressure allowed inside of the canister before it starts to break (different tiers have different limits)
	var/pressure_limit = 46000
	///Maximum amount of heat that the canister can handle before taking damage
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
	///Set the tier of the canister and overlay used
	var/mode = CANISTER_TIER_1
	///Window overlay showing the gas inside the canister
	var/image/window

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()

	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()

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
	if(mode)
		. += span_notice("This canister is Tier [mode]. A sticker on its side says <b>MAX SAFE PRESSURE: [siunit_pressure(initial(pressure_limit), 0)]</b>.")

// Please keep the canister types sorted
// Basic canister per gas below here

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Antinoblium canister"
	desc = "Antinoblium, we still don't know what it does, but it sells for a lot"
	gas_type = /datum/gas/antinoblium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	gas_type = /datum/gas/bz
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	gas_type = /datum/gas/carbon_dioxide
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	desc = "Freon. Can absorb heat"
	gas_type = /datum/gas/freon
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6696ee#fefb30"

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	desc = "Halon, removes oxygen from high temperature fires and cools down the area"
	gas_type = /datum/gas/halon
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	desc = "Healium, causes deep sleep"
	gas_type = /datum/gas/healium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#ff0e00"

/obj/machinery/portable_atmospherics/canister/helium
	name = "Helium canister"
	desc = "Helium, inert gas"
	gas_type = /datum/gas/helium
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	desc = "Hydrogen, highly flammable"
	gas_type = /datum/gas/hydrogen
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#bdc2c0#ffffff"

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	desc = "Miasma. Makes you wish your nose was blocked."
	gas_type = /datum/gas/miasma
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	gas_type = /datum/gas/nitrogen
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	gas_type = /datum/gas/nitrous_oxide
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	desc = "Nitrium gas. Feels great 'til the acid eats your lungs."
	gas_type = /datum/gas/nitrium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	gas_type = /datum/gas/hypernoblium
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	desc = "Oxygen. Necessary for human life."
	gas_type = /datum/gas/oxygen
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	gas_type = /datum/gas/pluoxium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/proto_nitrate
	name = "Proto Nitrate canister"
	desc = "Proto Nitrate, reacts differently with various gases"
	gas_type = /datum/gas/proto_nitrate
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#008200#33cc33"

/obj/machinery/portable_atmospherics/canister/plasma
	name = "Plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	gas_type = /datum/gas/plasma
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f62800#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	gas_type = /datum/gas/tritium
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	desc = "Water Vapor. We get it, you vape."
	gas_type = /datum/gas/water_vapor
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	desc = "Zauker, highly toxic"
	gas_type = /datum/gas/zauker
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009a00#006600"

// Special canisters below here

/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "fusion test canister"
	desc = "Don't be a badmin."
	heat_limit = 1e12
	pressure_limit = 1e14
	mode = CANISTER_TIER_3

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.add_gases(/datum/gas/hydrogen, /datum/gas/tritium)
	air_contents.gases[/datum/gas/hydrogen][MOLES] = 300
	air_contents.gases[/datum/gas/tritium][MOLES] = 300
	air_contents.temperature = 10000
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
	mode = NONE

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

/obj/machinery/portable_atmospherics/canister/tier_1
	heat_limit = 5000
	pressure_limit = 46000
	mode = CANISTER_TIER_1

/obj/machinery/portable_atmospherics/canister/tier_2
	heat_limit = 500000
	pressure_limit = 4600000
	volume = 3000
	max_integrity = 300
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	mode = CANISTER_TIER_2

/obj/machinery/portable_atmospherics/canister/tier_3
	heat_limit = 1e12
	pressure_limit = 9.2e13
	volume = 5000
	max_integrity = 500
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 50)
	mode = CANISTER_TIER_3

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
	var/isBroken = machine_stat & BROKEN
	///Function is used to actually set the overlays
	if(mode)
		. += mutable_appearance(canister_overlay_file, "tier[mode]")
	if(isBroken)
		. += mutable_appearance(canister_overlay_file, "broken")
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")

	var/air_pressure = air_contents.return_pressure()

	switch(air_pressure)
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			. += mutable_appearance(canister_overlay_file, "can-3")
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-2")
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-1")
		if((10) to (5 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-0")

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
	for(var/visual in air_contents.return_visuals())
		var/image/new_visual = image(visual, layer=FLOAT_LAYER)
		new_visual.filters = alpha_filter
		window_overlays += new_visual
	window.overlays = window_overlays
	add_overlay(window)

/obj/machinery/portable_atmospherics/canister/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > temperature_resistance * mode

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
	switch(mode)
		if(CANISTER_TIER_1)
			new /obj/item/stack/sheet/iron (drop_location(), 10)
		if(CANISTER_TIER_2)
			new /obj/item/stack/sheet/iron (drop_location(), 10)
			new /obj/item/stack/sheet/plasteel (drop_location(), 5)
		if(CANISTER_TIER_3)
			new /obj/item/stack/sheet/iron (drop_location(), 10)
			new /obj/item/stack/sheet/plasteel (drop_location(), 5)
			new /obj/item/stack/sheet/bluespace_crystal (drop_location(), 1)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, span_alert("The pressure gauge on [src] indicates a high pressure inside... maybe you want to reconsider?"))
		message_admins("[src] deconstructed by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] deconstructed by [key_name(user)]")
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

/obj/machinery/portable_atmospherics/canister/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(!.)
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
		investigate_log("Valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
	else if(valve_open && holding)
		investigate_log("[key_name(user)] started a transfer into [holding].", INVESTIGATE_ATMOS)

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

		if(air_contents.release_gas_to(target_air, release_pressure) && !holding)
			air_update_turf(FALSE, FALSE)

	var/our_pressure = air_contents.return_pressure()
	var/our_temperature = air_contents.return_temperature()

	///function used to check the limit of the canisters and also set the amount of damage that the canister can receive, if the heat and pressure are way higher than the limit the more damage will be done
	if(our_temperature > heat_limit || our_pressure > pressure_limit)
		take_damage(clamp((our_temperature/heat_limit) * (our_pressure/pressure_limit), 5, 50), BURN, 0)
		excited = TRUE
	update_appearance()

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
		"hasHoldingTank" = !!holding
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

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("relabel")
			var/label = tgui_input_list(usr, "New canister label", name, GLOB.gas_id_to_canister)
			if(label && !..())
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
				req_access = list(ACCESS_ENGINE)
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
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
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
					admin_msg = "[key_name(usr)] <b>opened</b> a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:"
					for(var/name in gaseslog)
						n = n + 1
						logmsg += "\n[name]: [gaseslog[name]] moles."
						if(n <= 5) //the first five gases added
							admin_msg += "\n[name]: [gaseslog[name]] moles."
						if(n == 5 && gaseslog.len > 5) //message added if more than 5 gases
							admin_msg += "\nToo many gases to log. Check investigate log."
					if(danger) //sent to admin's chat if contains dangerous gases
						message_admins(admin_msg)
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
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
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the [span_boldannounce("air")].")
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the [span_boldannounce("air")].", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	update_appearance()

/obj/machinery/portable_atmospherics/canister/unregister_holding()
	valve_open = FALSE
	return ..()
