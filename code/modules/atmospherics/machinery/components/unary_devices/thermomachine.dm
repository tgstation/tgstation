#define THERMOMACHINE_POWER_CONVERSION 0.01

/obj/machinery/atmospherics/components/unary/thermomachine
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "thermo_base"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	hide = TRUE

	move_resist = MOVE_RESIST_DEFAULT
	vent_movement = NONE
	pipe_flags = PIPING_ONE_PER_TURF

	greyscale_config = /datum/greyscale_config/thermomachine
	greyscale_colors = COLOR_VIBRANT_LIME

	set_dir_on_move = FALSE

	var/min_temperature = T20C //actual temperature will be defined by RefreshParts()
	var/max_temperature = T20C //actual temperature will be defined by RefreshParts()
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.
	var/base_heating = 140
	var/base_cooling = 170
	var/color_index = 1

/obj/machinery/atmospherics/components/unary/thermomachine/Initialize(mapload)
	. = ..()
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/unary/thermomachine/is_connectable()
	if(!anchored || panel_open)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer

	if(check_pipe_on_turf())
		deconstruct(TRUE)
		return
	return..()

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	. = ..()
	var/calculated_bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2)

	var/calculated_laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		calculated_laser_rating += laser.rating
	min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_state()
	var/colors_to_use = ""
	switch(target_temperature)
		if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
			colors_to_use = COLOR_RED
		if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			colors_to_use = COLOR_ORANGE
		if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
			colors_to_use = COLOR_YELLOW
		if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
			colors_to_use = COLOR_VIBRANT_LIME
		if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
			colors_to_use = COLOR_CYAN
		if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			colors_to_use = COLOR_BLUE
		else
			colors_to_use = COLOR_VIOLET

	if(greyscale_colors != colors_to_use)
		set_greyscale(colors=colors_to_use)

	if(panel_open)
		icon_state = "thermo-open"
		return ..()
	if(on && is_operational)
		icon_state = "thermo_1"
		return ..()
	icon_state = "thermo_base"
	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/update_overlays()
	. = ..()
	if(!initial(icon))
		return
	var/mutable_appearance/thermo_overlay = new(initial(icon))
	. += get_pipe_image(thermo_overlay, "pipe", dir, COLOR_LIME, piping_layer)

/obj/machinery/atmospherics/components/unary/thermomachine/examine(mob/user)
	. = ..()
	. += span_notice("With the panel open:")
	. += span_notice(" -Use a wrench with left-click to rotate [src] and right-click to unanchor it.")
	. += span_notice(" -Use a multitool with left-click to change the piping layer and right-click to change the piping color.")
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).")

	if(in_range(user, src) || isobserver(user))
		. += span_notice("Heat capacity at <b>[heat_capacity] Joules per Kelvin</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.")

/obj/machinery/atmospherics/components/unary/thermomachine/AltClick(mob/living/user)
	if(!can_interact(user))
		return
	target_temperature = T20C
	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "temperature reset to [target_temperature] K")
	update_appearance()

/** Performs heat calculation for the freezer. The full equation for this whole process is:
 * T3 = (C1 * T1 + (C1 * C2) / (C1 + C2) * (T2 - T1)) / C1.
 * C1 is main port heat capacity, T1 is the temp.
 * C2 and T2 is for the heat capacity of the freezer and temperature that we desire respectively.
 * T3 is the temperature we get
 */
/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	if(!on)
		return

	var/turf/local_turf = get_turf(src)

	if(!is_operational || !local_turf)
		on = FALSE
		update_appearance()
		return

	// The gas we want to cool/heat
	var/datum/gas_mixture/port = airs[1]

	if(!port.total_moles()) // Nothing to cool? go home lad
		return

	var/port_capacity = port.heat_capacity()

	// The difference between target and what we need to heat/cool. Positive if heating, negative if cooling.
	var/temperature_target_delta = target_temperature - port.temperature

	// This variable holds the (C1*C2) / (C1+C2) * (T2-T1) part of the equation.
	var/heat_amount = temperature_target_delta * (port_capacity * heat_capacity / (port_capacity + heat_capacity))

	port.temperature = max(((port.temperature * port_capacity) + heat_amount) / port_capacity, TCMB)

	heat_amount = min(abs(heat_amount), 1e8) * THERMOMACHINE_POWER_CONVERSION

	// This produces a nice curve that scales decently well for really hot stuff, and is nice to not fusion. It'll do
	var/power_usage = idle_power_usage + (heat_amount * 0.05) ** (1.05 - (5e7 * 0.16 / max(heat_amount, 5e7)))

	use_power(power_usage)
	update_parents()

/obj/machinery/atmospherics/components/unary/thermomachine/screwdriver_act(mob/living/user, obj/item/tool)
	if(on)
		to_chat(user, span_notice("You can't open [src] while it's on!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!anchored)
		to_chat(user, span_notice("Anchor [src] first!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(default_deconstruction_screwdriver(user, "thermo-open", "thermo-0", tool))
		change_pipe_connection(panel_open)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/thermomachine/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/atmospherics/components/unary/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!panel_open)
		return
	piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	set_init_directions()
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		return
	color_index = (color_index >= GLOB.pipe_paint_colors.len) ? (color_index = 1) : (color_index = 1 + color_index)
	pipe_color = GLOB.pipe_paint_colors[GLOB.pipe_paint_colors[color_index]]
	visible_message("<span class='notice'>You set [src]'s pipe color to [GLOB.pipe_color_name[pipe_color]].")
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/proc/check_pipe_on_turf()
	for(var/obj/machinery/atmospherics/device in get_turf(src))
		if(device == src)
			continue
		if(device.piping_layer == piping_layer)
			visible_message(span_warning("A pipe is hogging the port, remove the obstruction or change the machine piping layer."))
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/thermomachine/proc/change_pipe_connection(disconnect)
	if(disconnect)
		disconnect_pipes()
		return
	connect_pipes()

/obj/machinery/atmospherics/components/unary/thermomachine/proc/connect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	atmos_init()
	node1 = nodes[1]
	if(node1)
		node1.atmos_init()
		node1.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/thermomachine/proc/disconnect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullify_pipenet(parents[1])

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open || check_pipe_on_turf())
		return
	if(default_unfasten_wrench(user, tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return

/obj/machinery/atmospherics/components/unary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoMachine", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/port = airs[1]
	data["temperature"] = port.temperature
	data["pressure"] = port.return_pressure()
	return data

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			update_use_power(on ? ACTIVE_POWER_USE : IDLE_POWER_USE)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

	update_appearance()

/obj/machinery/atmospherics/components/unary/thermomachine/CtrlClick(mob/living/user)
	if(!panel_open)
		if(!can_interact(user))
			return
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
		return
	. = ..()

/obj/machinery/atmospherics/components/unary/thermomachine/update_layer()
	return

/obj/machinery/atmospherics/components/unary/thermomachine/freezer

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on
	on = TRUE
	icon_state = "thermo_base_1"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/Initialize(mapload)
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature
/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"
	icon_state = "thermo_base_1"
	greyscale_colors = COLOR_CYAN

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom/Initialize(mapload)
	. = ..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/machinery/atmospherics/components/unary/thermomachine/heater/on
	on = TRUE
	icon_state = "thermo_base_1"

#undef THERMOMACHINE_POWER_CONVERSION
