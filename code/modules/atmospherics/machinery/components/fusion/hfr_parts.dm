/**
 * This file contain the eight parts surrounding the main core, those are: fuel input, moderator input, waste output, interface and the corners
 * The file also contain the guicode of the machine
 */
/obj/machinery/atmospherics/components/unary/hypertorus
	icon = 'icons/obj/machines/atmospherics/hypertorus.dmi'
	icon_state = "core_off"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
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
	///Check if the machine is cracked open
	var/cracked = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/Initialize(mapload)
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/hypertorus/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.")

/obj/machinery/atmospherics/components/unary/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/welder_act(mob/living/user, obj/item/tool)
	if(!cracked)
		return FALSE
	if(user.combat_mode)
		return FALSE
	balloon_alert(user, "repairing...")
	if(tool.use_tool(src, user, 10 SECONDS, volume=30))
		balloon_alert(user, "repaired")
		cracked = FALSE
		update_appearance()

/obj/machinery/atmospherics/components/unary/hypertorus/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		set_init_directions()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
			if(parents[1])
				nullify_pipenet(parents[1])
		atmos_init()
		node = nodes[1]
		if(node)
			node.atmos_init()
			node.add_member(src)
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

/obj/machinery/atmospherics/components/unary/hypertorus/update_overlays()
	. = ..()
	if(!cracked)
		return
	var/image/crack = image(icon, icon_state = "crack")
	crack.dir = dir
	. += crack

/obj/machinery/atmospherics/components/unary/hypertorus/update_layer()
	return

/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	name = "HFR fuel input port"
	desc = "Input port for the Hypertorus Fusion Reactor, designed to take in fuels with the optimal fuel mix being a 50/50 split."
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
	icon = 'icons/obj/machines/atmospherics/hypertorus.dmi'
	icon_state = "core_off"
	move_resist = INFINITY
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	var/fusion_started = FALSE

/obj/machinery/hypertorus/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.")

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
	var/turf/T = get_step(src,REVERSE_DIR(dir))
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		to_chat(user, span_notice("Check all parts and then try again."))
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
		to_chat(user, span_notice("Activate the machine first by using a multitool on the interface."))

/obj/machinery/hypertorus/interface/proc/gas_list_to_gasid_list(list/gas_list)
	var/list/gasid_list = list()
	for(var/gas_type in gas_list)
		var/datum/gas/gas = gas_type
		gasid_list += initial(gas.id)
	return gasid_list



/obj/machinery/hypertorus/interface/ui_static_data()
	var/data = list()
	data["base_max_temperature"] = FUSION_MAXIMUM_TEMPERATURE
	data["selectable_fuel"] = list(list("name" = "Nothing", "id" = null))
	for(var/path in GLOB.hfr_fuels_list)
		var/datum/hfr_fuel/recipe = GLOB.hfr_fuels_list[path]

		data["selectable_fuel"] += list(list(
			"name" = recipe.name,
			"id" = recipe.id,
			"requirements" = gas_list_to_gasid_list(recipe.requirements),
			"fusion_byproducts" = gas_list_to_gasid_list(recipe.primary_products),
			"product_gases" = gas_list_to_gasid_list(recipe.secondary_products),
			"recipe_cooling_multiplier" = recipe.negative_temperature_multiplier,
			"recipe_heating_multiplier" = recipe.positive_temperature_multiplier,
			"energy_loss_multiplier" = recipe.energy_concentration_multiplier,
			"fuel_consumption_multiplier" = recipe.fuel_consumption_multiplier,
			"gas_production_multiplier" = recipe.gas_production_multiplier,
			"temperature_multiplier" = recipe.temperature_change_multiplier,
		))
	return data

/obj/machinery/hypertorus/interface/ui_data()
	var/data = list()

	if(connected_core.selected_fuel)
		data["selected"] = connected_core.selected_fuel.id
	else
		data["selected"] = ""

	//Internal Fusion gases
	var/list/fusion_gasdata = list()
	if(connected_core.internal_fusion.total_moles())
		for(var/gas_type in connected_core.internal_fusion.gases)
			var/datum/gas/gas = gas_type
			fusion_gasdata.Add(list(list(
			"id"= initial(gas.id),
			"amount" = round(connected_core.internal_fusion.gases[gas][MOLES], 0.01),
			)))
	else
		for(var/gas_type in connected_core.internal_fusion.gases)
			var/datum/gas/gas = gas_type
			fusion_gasdata.Add(list(list(
				"id"= initial(gas.id),
				"amount" = 0,
				)))
	//Moderator gases
	var/list/moderator_gasdata = list()
	if(connected_core.moderator_internal.total_moles())
		for(var/gas_type in connected_core.moderator_internal.gases)
			var/datum/gas/gas = gas_type
			moderator_gasdata.Add(list(list(
			"id"= initial(gas.id),
			"amount" = round(connected_core.moderator_internal.gases[gas][MOLES], 0.01),
			)))
	else
		for(var/gas_type in connected_core.moderator_internal.gases)
			var/datum/gas/gas = gas_type
			moderator_gasdata.Add(list(list(
				"id"= initial(gas.id),
				"amount" = 0,
				)))

	data["fusion_gases"] = fusion_gasdata
	data["moderator_gases"] = moderator_gasdata

	data["energy_level"] = connected_core.energy
	data["heat_limiter_modifier"] = connected_core.heat_limiter_modifier
	data["heat_output_min"] = connected_core.heat_output_min
	data["heat_output_max"] = connected_core.heat_output_max
	data["heat_output"] = connected_core.heat_output
	data["instability"] = connected_core.instability

	data["heating_conductor"] = connected_core.heating_conductor
	data["magnetic_constrictor"] = connected_core.magnetic_constrictor
	data["fuel_injection_rate"] = connected_core.fuel_injection_rate
	data["moderator_injection_rate"] = connected_core.moderator_injection_rate
	data["current_damper"] = connected_core.current_damper

	data["power_level"] = connected_core.power_level
	data["apc_energy"] = connected_core.get_area_cell_percent()
	data["iron_content"] = connected_core.iron_content
	data["integrity"] = connected_core.get_integrity_percent()

	data["start_power"] = connected_core.start_power
	data["start_cooling"] = connected_core.start_cooling
	data["start_fuel"] = connected_core.start_fuel
	data["start_moderator"] = connected_core.start_moderator

	data["internal_fusion_temperature"] = connected_core.fusion_temperature
	data["moderator_internal_temperature"] = connected_core.moderator_temperature
	data["internal_output_temperature"] = connected_core.output_temperature
	data["internal_coolant_temperature"] = connected_core.coolant_temperature

	data["internal_fusion_temperature_archived"] = connected_core.fusion_temperature_archived
	data["moderator_internal_temperature_archived"] = connected_core.moderator_temperature_archived
	data["internal_output_temperature_archived"] = connected_core.output_temperature_archived
	data["internal_coolant_temperature_archived"] = connected_core.coolant_temperature_archived
	data["temperature_period"] = connected_core.temperature_period

	data["waste_remove"] = connected_core.waste_remove
	data["filter_types"] = list()
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filter_types"] += list(list("gas_id" = gas[META_GAS_ID], "gas_name" = gas[META_GAS_NAME], "enabled" = (path in connected_core.moderator_scrubbing)))

	data["cooling_volume"] = connected_core.airs[1].volume
	data["mod_filtering_rate"] = connected_core.moderator_filtering_rate

	return data

/obj/machinery/hypertorus/interface/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_power")
			connected_core.start_power = !connected_core.start_power
			connected_core.update_use_power(connected_core.start_power ? ACTIVE_POWER_USE : IDLE_POWER_USE)
			. = TRUE
		if("start_cooling")
			connected_core.start_cooling = !connected_core.start_cooling
			. = TRUE
		if("start_fuel")
			connected_core.start_fuel = !connected_core.start_fuel
			. = TRUE
		if("start_moderator")
			connected_core.start_moderator = !connected_core.start_moderator
			. = TRUE
		if("heating_conductor")
			var/heating_conductor = text2num(params["heating_conductor"])
			if(heating_conductor != null)
				connected_core.heating_conductor = clamp(heating_conductor, 50, 500)
				. = TRUE
		if("magnetic_constrictor")
			var/magnetic_constrictor = text2num(params["magnetic_constrictor"])
			if(magnetic_constrictor != null)
				connected_core.magnetic_constrictor = clamp(magnetic_constrictor, 50, 1000)
				. = TRUE
		if("fuel_injection_rate")
			var/fuel_injection_rate = text2num(params["fuel_injection_rate"])
			if(fuel_injection_rate != null)
				connected_core.fuel_injection_rate = clamp(fuel_injection_rate, 0.5, 150)
				. = TRUE
		if("moderator_injection_rate")
			var/moderator_injection_rate = text2num(params["moderator_injection_rate"])
			if(moderator_injection_rate != null)
				connected_core.moderator_injection_rate = clamp(moderator_injection_rate, 0.5, 150)
				. = TRUE
		if("current_damper")
			var/current_damper = text2num(params["current_damper"])
			if(current_damper != null)
				connected_core.current_damper = clamp(current_damper, 0, 1000)
				. = TRUE
		if("waste_remove")
			connected_core.waste_remove = !connected_core.waste_remove
			. = TRUE
		if("filter")
			connected_core.moderator_scrubbing ^= gas_id2path(params["mode"])
			. = TRUE
		if("mod_filtering_rate")
			var/mod_filtering_rate = text2num(params["mod_filtering_rate"])
			if(mod_filtering_rate != null)
				connected_core.moderator_filtering_rate = clamp(mod_filtering_rate, 5, 200)
				. = TRUE
		if("fuel")
			connected_core.selected_fuel = null
			var/fuel_mix = "nothing"
			var/datum/hfr_fuel/fuel = null
			if(params["mode"] != "")
				fuel = GLOB.hfr_fuels_list[params["mode"]]
			if(fuel)
				connected_core.selected_fuel = fuel
				fuel_mix = fuel.name
			if(connected_core.internal_fusion.total_moles())
				connected_core.dump_gases()
			connected_core.update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
			connected_core.linked_input.update_parents()
			connected_core.linked_output.update_parents()
			connected_core.linked_moderator.update_parents()
			investigate_log("was set to recipe [fuel_mix ? fuel_mix : "null"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("cooling_volume")
			var/cooling_volume = text2num(params["cooling_volume"])
			if(cooling_volume != null)
				connected_core.airs[1].volume = clamp(cooling_volume, 50, 2000)
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
	default_raw_text = "<B>How to safely(TM) operate the Hypertorus</B><BR>\
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

/obj/item/hfr_box
	name = "HFR box"
	desc = "If you see this, call the police."
	icon = 'icons/obj/machines/atmospherics/hypertorus.dmi'
	icon_state = "error"
	///What kind of box are we handling?
	var/box_type = "impossible"
	///What's the path of the machine we making
	var/part_path

/obj/item/hfr_box/corner
	name = "HFR box corner"
	desc = "Place this as the corner of your 3x3 multiblock fusion reactor"
	icon_state = "box_corner"
	box_type = "corner"
	part_path = /obj/machinery/hypertorus/corner

/obj/item/hfr_box/body
	name = "HFR box body"
	desc = "Place this on the sides of the core box of your 3x3 multiblock fusion reactor"
	box_type = "body"
	icon_state = "box_body"

/obj/item/hfr_box/body/fuel_input
	name = "HFR box fuel input"
	icon_state = "box_fuel"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/fuel_input

/obj/item/hfr_box/body/moderator_input
	name = "HFR box moderator input"
	icon_state = "box_moderator"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/moderator_input

/obj/item/hfr_box/body/waste_output
	name = "HFR box waste output"
	icon_state = "box_waste"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/waste_output

/obj/item/hfr_box/body/interface
	name = "HFR box interface"
	part_path = /obj/machinery/hypertorus/interface

/obj/item/hfr_box/core
	name = "HFR box core"
	desc = "Activate this with a multitool to deploy the full machine after setting up the other boxes"
	icon_state = "box_core"
	box_type = "core"
	part_path = /obj/machinery/atmospherics/components/unary/hypertorus/core

/obj/item/hfr_box/core/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/list/parts = list()
	for(var/obj/item/hfr_box/box in orange(1,src))
		var/direction = get_dir(src, box)
		if(box.box_type == "corner")
			if(ISDIAGONALDIR(direction))
				switch(direction)
					if(NORTHEAST)
						direction = EAST
					if(SOUTHEAST)
						direction = SOUTH
					if(SOUTHWEST)
						direction = WEST
					if(NORTHWEST)
						direction = NORTH
				box.dir = direction
				parts |= box
			continue
		if(box.box_type == "body")
			if(direction in GLOB.cardinals)
				box.dir = direction
				parts |= box
			continue
	if(parts.len == 8)
		build_reactor(parts)
	return

/obj/item/hfr_box/core/proc/build_reactor(list/parts)
	for(var/obj/item/hfr_box/box in parts)
		if(box.box_type == "corner")
			var/obj/machinery/hypertorus/corner/corner = new box.part_path(box.loc)
			corner.dir = box.dir
			qdel(box)
			continue
		if(box.box_type == "body")
			var/location = get_turf(box)
			if(box.part_path != /obj/machinery/hypertorus/interface)
				var/obj/machinery/atmospherics/components/unary/hypertorus/part = new box.part_path(location, TRUE, box.dir)
				part.dir = box.dir
			else
				var/obj/machinery/hypertorus/interface/part = new box.part_path(location)
				part.dir = box.dir
			qdel(box)
			continue

	new/obj/machinery/atmospherics/components/unary/hypertorus/core(loc, TRUE)
	qdel(src)
