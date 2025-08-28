/obj/machinery/atmospherics/components/unary/outlet_injector
	icon_state = "inje_map-3"

	name = "air injector"
	desc = "Has a valve and pump attached to it."

	use_power = IDLE_POWER_USE
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	hide = TRUE
	layer = GAS_SCRUBBER_LAYER
	pipe_state = "injector"
	has_cap_visuals = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.25

	///Rate of operation of the device
	var/volume_rate = 50

/obj/machinery/atmospherics/components/unary/outlet_injector/Initialize(mapload)
	if(isnull(id_tag))
		id_tag = assign_random_name()
	. = ..()

	var/static/list/tool_screentips
	if(!tool_screentips)
		tool_screentips = string_assoc_nested_list(list(
			TOOL_MULTITOOL = list(
				SCREENTIP_CONTEXT_LMB = "Log to link later with air sensor",
			)
		))
	AddElement(/datum/element/contextual_screentip_tools, tool_screentips)
	register_context()

/obj/machinery/atmospherics/components/unary/outlet_injector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Maximize transfer rate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/unary/outlet_injector/examine(mob/user)
	. = ..()
	. += span_notice("You can link it with an air sensor using a multitool.")

/obj/machinery/atmospherics/components/unary/outlet_injector/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	if(istype(multi_tool.buffer, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/sensor = multi_tool.buffer
		multi_tool.set_buffer(src)
		sensor.multitool_act(user, multi_tool)
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "injector saved in buffer")
	multi_tool.set_buffer(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/outlet_injector/click_ctrl(mob/user)
	if(is_operational)
		set_on(!on)
		balloon_alert(user, "turned [on ? "on" : "off"]")
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		return CLICK_ACTION_BLOCKING
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/unary/outlet_injector/click_alt(mob/user)
	if(volume_rate == MAX_TRANSFER_RATE)
		return CLICK_ACTION_BLOCKING

	volume_rate = MAX_TRANSFER_RATE
	investigate_log("was set to [volume_rate] L/s by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "volume output set to [volume_rate] L/s")
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/unary/outlet_injector/update_icon_nopipes()
	cut_overlays()
	if(underfloor_state)
		// everything is already shifted so don't shift the cap
		var/image/cap = get_pipe_image(icon, "inje_cap", initialize_directions, pipe_color)
		cap.appearance_flags |= RESET_COLOR|KEEP_APART
		add_overlay(cap)
	else
		PIPING_LAYER_SHIFT(src, PIPING_LAYER_DEFAULT)

	if(!nodes[1] || !on || !is_operational)
		icon_state = "inje_off"
	else
		icon_state = "inje_on"

/obj/machinery/atmospherics/components/unary/outlet_injector/process_atmos()
	..()
	if(!on || !is_operational)
		return

	var/turf/location = get_turf(loc)
	if(isclosedturf(location))
		return

	var/datum/gas_mixture/air_contents = airs[1]

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure() * volume_rate) / (air_contents.temperature * R_IDEAL_GAS_EQUATION)

		if(!transfer_moles)
			return

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		location.assume_air(removed)

		update_parents()

/obj/machinery/atmospherics/components/unary/outlet_injector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/outlet_injector/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(volume_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)
	return data

/obj/machinery/atmospherics/components/unary/outlet_injector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			set_on(!on)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = MAX_TRANSFER_RATE
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				volume_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
				investigate_log("was set to [volume_rate] L/s by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/unary/outlet_injector/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

// mapping

/obj/machinery/atmospherics/components/unary/outlet_injector/layer2
	piping_layer = 2
	icon_state = "inje_map-2"

/obj/machinery/atmospherics/components/unary/outlet_injector/layer4
	piping_layer = 4
	icon_state = "inje_map-4"

/obj/machinery/atmospherics/components/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/components/unary/outlet_injector/on/layer2
	piping_layer = 2
	icon_state = "inje_map-2"

/obj/machinery/atmospherics/components/unary/outlet_injector/on/layer4
	piping_layer = 4
	icon_state = "inje_map-4"
