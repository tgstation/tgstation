/**
 * This file contain the eight parts surrounding the main core, those are: fuel input, moderator input, waste output, interface and the corners
 * The file also contain the guicode of the machine
 */
/obj/machinery/atmospherics/components/unary/hypertorus
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	layer = OBJ_LAYER
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	///Vars for the state of the icon of the object (open, off, active)
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	///Check if the machine has been activated
	var/active = FALSE
	///Check if fusion has started
	var/fusion_started = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/Initialize()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/atmospherics/components/unary/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
			nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/hypertorus/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	name = "HFR fuel input port"
	desc = "Input port for the Hypertorus Fusion Reactor, designed to take in only Hydrogen and Tritium in gas forms."
	icon_state = "fuel_input_off"
	icon_state_open = "fuel_input_open"
	icon_state_off = "fuel_input_off"
	icon_state_active = "fuel_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_fuel_input

/obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	name = "HFR waste output port"
	desc = "Waste port for the Hypertorus Fusion Reactor, designed to output the hot waste gases coming from the core of the machine."
	icon_state = "waste_output_off"
	icon_state_open = "waste_output_open"
	icon_state_off = "waste_output_off"
	icon_state_active = "waste_output_active"
	circuit = /obj/item/circuitboard/machine/HFR_waste_output

/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	name = "HFR moderator input port"
	desc = "Moderator port for the Hypertorus Fusion Reactor, designed to move gases inside the machine to cool and control the flow of the reaction."
	icon_state = "moderator_input_off"
	icon_state_open = "moderator_input_open"
	icon_state_off = "moderator_input_off"
	icon_state_active = "moderator_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_moderator_input

/*
* Interface and corners
*/
/obj/machinery/hypertorus
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"
	move_resist = INFINITY
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	var/fusion_started = FALSE

/obj/machinery/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/hypertorus/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(active)
		icon_state = icon_state_active
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/hypertorus/interface
	name = "HFR interface"
	desc = "Interface for the HFR to control the flow of the reaction."
	icon_state = "interface_off"
	circuit = /obj/item/circuitboard/machine/HFR_interface
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/connected_core
	icon_state_off = "interface_off"
	icon_state_open = "interface_open"
	icon_state_active = "interface_active"

/obj/machinery/hypertorus/interface/Destroy()
	if(connected_core)
		connected_core = null
	return..()

/obj/machinery/hypertorus/interface/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		to_chat(user, "<span class='notice'>Check all parts and then try again.</span>")
		return TRUE
	new/obj/item/paper/guides/jobs/atmos/hypertorus(loc)
	connected_core = centre

	connected_core.activate(user)
	return TRUE

/obj/machinery/hypertorus/interface/ui_interact(mob/user, datum/tgui/ui)
	if(active)
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Hypertorus", name)
			ui.open()
	else
		to_chat(user, "<span class='notice'>Activate the machine first by using a multitool on the interface.</span>")

/obj/machinery/hypertorus/interface/ui_data()
	var/data = list()
	//Internal Fusion gases
	var/list/fusion_gasdata = list()
	if(connected_core.internal_fusion.total_moles())
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
			"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.internal_fusion.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
				"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))
	//Moderator gases
	var/list/moderator_gasdata = list()
	if(connected_core.moderator_internal.total_moles())
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
			"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.moderator_internal.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
				"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))

	data["fusion_gases"] = fusion_gasdata
	data["moderator_gases"] = moderator_gasdata

	data["energy_level"] = connected_core.energy
	data["heat_limiter_modifier"] = connected_core.heat_limiter_modifier
	data["heat_output"] = abs(connected_core.heat_output)
	data["heat_output_bool"] = connected_core.heat_output >= 0 ? "" : "-"

	data["heating_conductor"] = connected_core.heating_conductor
	data["magnetic_constrictor"] = connected_core.magnetic_constrictor
	data["fuel_injection_rate"] = connected_core.fuel_injection_rate
	data["moderator_injection_rate"] = connected_core.moderator_injection_rate
	data["current_damper"] = connected_core.current_damper

	data["power_level"] = connected_core.power_level
	data["iron_content"] = connected_core.iron_content
	data["integrity"] = connected_core.get_integrity()

	data["start_power"] = connected_core.start_power
	data["start_cooling"] = connected_core.start_cooling
	data["start_fuel"] = connected_core.start_fuel

	data["internal_fusion_temperature"] = connected_core.fusion_temperature
	data["moderator_internal_temperature"] = connected_core.moderator_temperature
	data["internal_output_temperature"] = connected_core.output_temperature
	data["internal_coolant_temperature"] = connected_core.coolant_temperature

	data["waste_remove"] = connected_core.waste_remove
	data["filter_types"] = list()
	data["filter_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !connected_core.filter_type))
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filter_types"] += list(list("name" = gas[META_GAS_NAME], "id" = gas[META_GAS_ID], "selected" = (path == gas_id2path(connected_core.filter_type))))

	return data

/obj/machinery/hypertorus/interface/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_power")
			connected_core.start_power = !connected_core.start_power
			connected_core.use_power = connected_core.start_power ? ACTIVE_POWER_USE : IDLE_POWER_USE
			. = TRUE
		if("start_cooling")
			connected_core.start_cooling = !connected_core.start_cooling
			. = TRUE
		if("start_fuel")
			connected_core.start_fuel = !connected_core.start_fuel
			. = TRUE
		if("heating_conductor")
			var/heating_conductor = params["heating_conductor"]
			if(text2num(heating_conductor) != null)
				heating_conductor = text2num(heating_conductor)
				. = TRUE
			if(.)
				connected_core.heating_conductor = clamp(heating_conductor, 50, 500)
		if("magnetic_constrictor")
			var/magnetic_constrictor = params["magnetic_constrictor"]
			if(text2num(magnetic_constrictor) != null)
				magnetic_constrictor = text2num(magnetic_constrictor)
				. = TRUE
			if(.)
				connected_core.magnetic_constrictor = clamp(magnetic_constrictor, 50, 1000)
		if("fuel_injection_rate")
			var/fuel_injection_rate = params["fuel_injection_rate"]
			if(text2num(fuel_injection_rate) != null)
				fuel_injection_rate = text2num(fuel_injection_rate)
				. = TRUE
			if(.)
				connected_core.fuel_injection_rate = clamp(fuel_injection_rate, 5, 1500)
		if("moderator_injection_rate")
			var/moderator_injection_rate = params["moderator_injection_rate"]
			if(text2num(moderator_injection_rate) != null)
				moderator_injection_rate = text2num(moderator_injection_rate)
				. = TRUE
			if(.)
				connected_core.moderator_injection_rate = clamp(moderator_injection_rate, 5, 1500)
		if("current_damper")
			var/current_damper = params["current_damper"]
			if(text2num(current_damper) != null)
				current_damper = text2num(current_damper)
				. = TRUE
			if(.)
				connected_core.current_damper = clamp(current_damper, 0, 1000)
		if("waste_remove")
			connected_core.waste_remove = !connected_core.waste_remove
			. = TRUE
		if("filter")
			connected_core.filter_type = null
			var/filter_name = "nothing"
			var/gas = gas_id2path(params["mode"])
			if(gas in GLOB.meta_gas_info)
				connected_core.filter_type = gas
				filter_name = GLOB.meta_gas_info[gas][META_GAS_NAME]
			investigate_log("was set to filter [filter_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE

/obj/machinery/hypertorus/corner
	name = "HFR corner"
	desc = "Structural piece of the machine."
	icon_state = "corner_off"
	circuit = /obj/item/circuitboard/machine/HFR_corner
	icon_state_off = "corner_off"
	icon_state_open = "corner_open"
	icon_state_active = "corner_active"

/obj/item/paper/guides/jobs/atmos/hypertorus
	name = "paper- 'Quick guide to safe handling of the HFR'"
	info = "<B>How to safely(TM) operate the Hypertorus</B><BR>\
	-Build the machine as it�s shown in the main guide.<BR>\
	-Make a 50/50 gasmix of tritium and hydrogen totalling around 2000 moles.<BR>\
	-Start the machine, fill up the cooling loop with plasma/hypernoblium and use space or freezers to cool it.<BR>\
	-Connect the fuel mix into the fuel injector port, allow only 1000 moles into the machine to ease the kickstart of the reaction<BR>\
	-Set the Heat conductor to 500 when starting the reaction, reset it to 100 when power level is higher than 1<BR>\
	-In the event of a meltdown, set the heat conductor to max and set the current damper to max. Set the fuel injection to min. \
	If the heat output doesn�t go negative, try changing the magnetic costrictors untill heat output goes negative. \
	Make the cooling stronger, put high heat capacity gases inside the moderator (hypernoblium will help dealing with the problem)<BR><BR>\
	<B>Warnings:</B><BR>\
	-You cannot dismantle the machine if the power level is over 0<BR>\
	-You cannot power of the machine if the power level is over 0<BR>\
	-You cannot dispose of waste gases if power level is over 5<BR>\
	-You cannot remove gases from the fusion mix if they are not helium and antinoblium<BR>\
	-Hypernoblium will decrease the power of the mix by a lot<BR>\
	-Antinoblium will INCREASE the power of the mix by a lot more<BR>\
	-High heat capacity gases are harder to heat/cool<BR>\
	-Low heat capacity gases are easier to heat/cool<BR>\
	-The machine consumes 50 KW per power level, reaching 350 KW at power level 6 so prepare the SM accordingly<BR>\
	-In case of a power shortage, the fusion reaction will CONTINUE but the cooling will STOP<BR><BR>\
	The writer of the quick guide will not be held responsible for misuses and meltdown caused by the use of the guide, \
	use more advanced guides to understando how the various gases will act as moderators."
