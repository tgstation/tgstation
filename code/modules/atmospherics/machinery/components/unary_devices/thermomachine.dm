#define THERMOMACHINE_POWER_CONVERSION 0.01

/obj/machinery/atmospherics/components/unary/thermomachine
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/machinery/atmospherics/components/unary/thermomachine"
	post_init_icon_state = "thermo_base"
	plane = GAME_PLANE

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	density = TRUE
	max_integrity = 300
	armor_type = /datum/armor/unary_thermomachine
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

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

/datum/armor/unary_thermomachine
	energy = 100
	fire = 80
	acid = 30

/obj/machinery/atmospherics/components/unary/thermomachine/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)
	register_context()

/obj/machinery/atmospherics/components/unary/thermomachine/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Cycle temperature"
	if(!held_item)
		return CONTEXTUAL_SCREENTIP_SET
	switch(held_item.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		if(TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "Rotate"
			context[SCREENTIP_CONTEXT_RMB] = "[anchored ? "Unan" : "An"]chor"
		if(TOOL_MULTITOOL)
			context[SCREENTIP_CONTEXT_LMB] = "Change piping layer"
			context[SCREENTIP_CONTEXT_RMB] = "Change piping color"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/unary/thermomachine/is_connectable()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction(mob/user, obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer

	..() //Skipping the rest of on_construction() would be a bad idea so we clean up after it instead.

	if(check_pipe_on_turf())
		set_anchored(FALSE)
		set_panel_open(TRUE)
		icon_state = "thermo-open"
		balloon_alert(user, "the port is already in use!")

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	. = ..()
	var/calculated_bin_rating = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.tier
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2)

	var/calculated_laser_rating = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		calculated_laser_rating += laser.tier
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
	var/image/pipe = get_pipe_image('icons/obj/machines/atmospherics/thermomachine.dmi', "pipe", dir, pipe_color, piping_layer)
	pipe.appearance_flags |= RESET_COLOR | KEEP_APART
	. += pipe

/obj/machinery/atmospherics/components/unary/thermomachine/examine(mob/user)
	. = ..()
	. += span_notice("With the panel open:")
	. += span_notice(" -Use a wrench with left-click to rotate [src] and right-click to unanchor it.")
	. += span_notice(" -Use a multitool with left-click to change the piping layer and right-click to change the piping color.")
	. += span_notice(" -[EXAMINE_HINT("AltClick")] to cycle between temperaure ranges.")
	. += span_notice(" -[EXAMINE_HINT("CtrlClick")] to toggle on/off.")
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).")

	if(in_range(user, src) || isobserver(user))
		. += span_notice("Heat capacity at <b>[heat_capacity] Joules per Kelvin</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.")

/obj/machinery/atmospherics/components/unary/thermomachine/click_alt(mob/living/user)
	if(panel_open)
		balloon_alert(user, "close panel!")
		return CLICK_ACTION_BLOCKING

	if(target_temperature == T20C)
		target_temperature = max_temperature
	else if(target_temperature == max_temperature)
		target_temperature = min_temperature
	else
		target_temperature = T20C

	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "temperature reset to [target_temperature] K")
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS

/// Performs heat calculation for the freezer.
/// We just equalize the gasmix with an object at temp = var/target_temperature and heat cap = var/heat_capacity
/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	if(!on)
		return

	var/turf/local_turf = get_turf(src)

	if(!is_operational || !local_turf)
		set_on(FALSE)
		return

	// The gas we want to cool/heat
	var/datum/gas_mixture/port = airs[1]

	if(!port.total_moles()) // Nothing to cool? go home lad
		return

	var/port_capacity = port.heat_capacity()

	// The difference between target and what we need to heat/cool. Positive if heating, negative if cooling.
	var/temperature_target_delta = target_temperature - port.temperature

	// We perfectly can do W1+W2 / C1+C2 here but this lets us count the power easily.
	var/heat_amount = CALCULATE_CONDUCTION_ENERGY(temperature_target_delta, port_capacity, heat_capacity)

	port.temperature = max(((port.temperature * port_capacity) + heat_amount) / port_capacity, TCMB)

	heat_amount = min(abs(heat_amount), 1e8) * THERMOMACHINE_POWER_CONVERSION

	// This produces a nice curve that scales decently well for really hot stuff, and is nice to not fusion. It'll do
	var/power_usage = idle_power_usage + (heat_amount * 0.05) ** (1.05 - (5e7 * 0.16 / max(heat_amount, 5e7)))

	use_energy(power_usage)
	update_parents()

/obj/machinery/atmospherics/components/unary/thermomachine/screwdriver_act(mob/living/user, obj/item/tool)
	if(on)
		balloon_alert(user, "turn off!")
		return ITEM_INTERACT_SUCCESS
	if(!anchored)
		balloon_alert(user, "anchor!")
		return ITEM_INTERACT_SUCCESS
	if(default_deconstruction_screwdriver(user, "thermo-open", "thermo-0", tool))
		update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/thermomachine/crowbar_act(mob/living/user, obj/item/tool)
	return crowbar_deconstruction_act(user, tool)

/obj/machinery/atmospherics/components/unary/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!panel_open)
		balloon_alert(user, "open panel!")
		return ITEM_INTERACT_SUCCESS
	piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
	if(anchored)
		reconnect_nodes()
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open panel!")
		return ITEM_INTERACT_SUCCESS
	color_index = (color_index >= GLOB.pipe_paint_colors.len) ? (color_index = 1) : (color_index = 1 + color_index)
	set_pipe_color(GLOB.pipe_paint_colors[GLOB.pipe_paint_colors[color_index]])
	visible_message(span_notice("[user] set [src]'s pipe color to [GLOB.pipe_color_name[pipe_color]]."), ignored_mobs = user)
	to_chat(user, span_notice("You set [src]'s pipe color to [GLOB.pipe_color_name[pipe_color]]."))
	if(anchored)
		reconnect_nodes()
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/proc/check_pipe_on_turf()
	for(var/obj/machinery/atmospherics/device in get_turf(src))
		if(device == src)
			continue
		if(device.piping_layer == piping_layer)
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/thermomachine/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open || check_pipe_on_turf())
		visible_message(span_warning("A pipe is hogging the port, remove the obstruction or change the machine piping layer."))
		return ITEM_INTERACT_SUCCESS
	if(default_unfasten_wrench(user, tool))
		change_pipe_connection(!anchored)
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/atmospherics/components/unary/thermomachine/ui_status(mob/user, datum/ui_state/state)
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

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			set_on(!on)
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

	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/unary/thermomachine/click_ctrl(mob/user)
	if(!anchored)
		return NONE
	if(panel_open)
		balloon_alert(user, "close panel!")
		return CLICK_ACTION_BLOCKING
	if(!is_operational)
		return CLICK_ACTION_BLOCKING

	set_on(!on)
	balloon_alert(user, "turned [on ? "on" : "off"]")
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/unary/thermomachine/update_layer()
	return

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/layer1
	piping_layer = 1

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/layer2
	piping_layer = 2

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/layer4
	piping_layer = 4

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/layer5
	piping_layer = 5

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on
	icon_state = "/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on"
	post_init_icon_state = "thermo_1"
	flags_1 = /obj/machinery/atmospherics/components/unary/thermomachine::flags_1 // we want this one to generate a preview
	on = TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/Initialize(mapload)
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"
	icon_state = "/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom"
	greyscale_colors = COLOR_CYAN

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom/Initialize(mapload)
	. = ..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/obj/machinery/atmospherics/components/unary/thermomachine/heater/layer1
	piping_layer = 1

/obj/machinery/atmospherics/components/unary/thermomachine/heater/layer2
	piping_layer = 2

/obj/machinery/atmospherics/components/unary/thermomachine/heater/layer4
	piping_layer = 4

/obj/machinery/atmospherics/components/unary/thermomachine/heater/layer5
	piping_layer = 5

/obj/machinery/atmospherics/components/unary/thermomachine/heater/on
	icon_state = "/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on" // same icon as the freezer
	post_init_icon_state = "thermo_1"
	on = TRUE

#undef THERMOMACHINE_POWER_CONVERSION
