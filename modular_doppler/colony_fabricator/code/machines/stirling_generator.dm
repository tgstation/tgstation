// Stirling generator, like a miniature TEG, pipe hot air in, and keep the air around it cold

/obj/machinery/power/stirling_generator
	name = "stirling generator"
	desc = "An industrial scale stirling generator. Stirling generators operate by intaking \
		hot gasses through their inlet pipes, and being cooled by the ambient air around them. \
		The cycling compression and expansion caused by this creates power, and this one is made \
		to make power on the scale of small stations and outposts."
	icon = 'modular_doppler/colony_fabricator/icons/stirling_generator/big_generator.dmi'
	icon_state = "stirling"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = null
	max_integrity = 300
	armor_type = /datum/armor/unary_thermomachine
	set_dir_on_move = FALSE
	can_change_cable_layer = TRUE
	/// Reference to the datum connector we're using to interface with the pipe network
	var/datum/gas_machine_connector/connected_chamber
	/// What this thing deconstructs into
	var/deconstruction_type = /obj/item/flatpacked_machine/stirling_generator
	/// Maximum efficient heat difference, at what heat difference does more difference stop meaning anything for power?
	var/max_efficient_heat_difference = 8000
	/// Maximum power output from this machine
	var/max_power_output = 100 KILO WATTS
	/// How much power the generator is currently making
	var/current_power_generation
	/// Our looping fan sound that we play when turned on
	var/datum/looping_sound/ore_thumper_fan/soundloop


/obj/machinery/power/stirling_generator/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	connected_chamber = new(loc, src, dir, CELL_VOLUME * 0.5)
	connect_to_network()
	AddElement(/datum/element/repackable, deconstruction_type, 10 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	// This is just to make sure our atmos connection spawns facing the right way
	setDir(dir)

/obj/machinery/power/stirling_generator/examine(mob/user)
	. = ..()
	. += span_notice("You can use a <b>wrench</b> with <b>Left-Click</b> to rotate the generator.")
	. += span_notice("It will not work in a <b>vacuum</b> as it must be cooled by the gas around it.")
	. += span_notice("It is currently generating <b>[display_power(current_power_generation, convert = FALSE)]</b> of power.")
	. += span_notice("It has a maximum power output of <b>[display_power(max_power_output, convert = FALSE)]</b> at a temperature difference of <b>[max_efficient_heat_difference] K</b>.")


/obj/machinery/power/stirling_generator/Destroy()
	QDEL_NULL(connected_chamber)
	return ..()


/obj/machinery/power/stirling_generator/process_atmos()
	if(!powernet)
		connect_to_network()
		if(!powernet)
			return

	var/turf/our_turf = get_turf(src)

	var/datum/gas_mixture/hot_air_from_pipe = connected_chamber.gas_connector.airs[1]
	var/datum/gas_mixture/environment = our_turf.return_air()

	if(!QUANTIZE(hot_air_from_pipe.total_moles()) || !QUANTIZE(environment.total_moles())) //Don't transfer if there's no gas
		return

	var/gas_temperature_delta = hot_air_from_pipe.temperature - environment.temperature

	if(!(gas_temperature_delta > 0))
		current_power_generation = 0
		return

	var/input_capacity = hot_air_from_pipe.heat_capacity()
	var/output_capacity = environment.heat_capacity()
	var/cooling_heat_amount = CALCULATE_CONDUCTION_ENERGY(gas_temperature_delta, input_capacity, output_capacity)
	hot_air_from_pipe.temperature = max(hot_air_from_pipe.temperature - (cooling_heat_amount / input_capacity), TCMB)

	/// Takes the amount of heat moved, and divides it by the maximum temperature difference we expect, creating a number to divide power generation by
	var/effective_energy_transfer = round((max_efficient_heat_difference / min(gas_temperature_delta, max_efficient_heat_difference)), 0.01)
	current_power_generation = round(max_power_output / effective_energy_transfer)


/obj/machinery/power/stirling_generator/process()
	var/power_output = round(current_power_generation)
	add_avail(power_to_energy(power_output))
	var/new_icon_state = (power_output ? "stirling_on" : "stirling")
	icon_state = new_icon_state
	if(soundloop.is_active() && !power_output)
		soundloop.stop()
	else if(!soundloop.is_active() && power_output)
		soundloop.start()


/obj/machinery/power/stirling_generator/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return


/obj/machinery/power/stirling_generator/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return


/obj/machinery/power/stirling_generator/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)


/obj/machinery/power/stirling_generator/default_change_direction_wrench(mob/user, obj/item/wrench)
	if(wrench.tool_behaviour != TOOL_WRENCH)
		return FALSE

	wrench.play_tool_sound(src, 50)
	setDir(turn(dir,-90))
	to_chat(user, span_notice("You rotate [src]."))
	SEND_SIGNAL(src, COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH, user, wrench)
	return TRUE


/obj/machinery/power/stirling_generator/Destroy()
	QDEL_NULL(connected_chamber)
	return ..()


// Item for creating stirling generators

/obj/item/flatpacked_machine/stirling_generator
	name = "flat-packed stirling generator"
	icon = 'modular_doppler/colony_fabricator/icons/stirling_generator/packed_machines.dmi'
	icon_state = "stirling"
	type_to_deploy = /obj/machinery/power/stirling_generator
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5,
	)
