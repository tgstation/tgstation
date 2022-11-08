/// GENERAL AIR CONTROL (a.k.a atmos computer)
/obj/machinery/computer/atmos_control
	name = "atmospherics monitoring"
	desc = "Used to monitor the station's atmospherics sensors."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control
	light_color = LIGHT_COLOR_CYAN

	/// Which sensors/input/outlets do we want to listen to.
	/// Assoc of list[chamber_id] = readable_chamber_name
	var/list/atmos_chambers

	/// Whether we can actually adjust the chambers or not.
	var/control = TRUE

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole", name)
		ui.open()

/obj/machinery/computer/atmos_control/ui_static_data(mob/user)
	var/data = list()
	data["maxInput"] = MAX_TRANSFER_RATE
	data["maxOutput"] = MAX_OUTPUT_PRESSURE
	data["control"] = control
	data += return_atmos_handbooks()
	return data

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()

	data["chambers"] = list()
	for(var/chamber_id in atmos_chambers)
		var/list/chamber_info = list()
		chamber_info["id"] = chamber_id
		chamber_info["name"] = atmos_chambers[chamber_id]

		var/obj/machinery/sensor = GLOB.objects_by_id_tag["[chamber_id]_sensor"]
		if (!isnull(sensor))
			chamber_info["gasmix"] = gas_mixture_parser(sensor.return_air())

		var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber_id]_in"]
		if (!isnull(input))
			chamber_info["input_info"] = list(
				"active" = input.on,
				"amount" = input.volume_rate,
			)

		var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber_id]_out"]
		if (!isnull(output))
			chamber_info["output_info"] = list(
				"active" = output.on,
				"amount" = output.internal_pressure_bound,
			)

		data["chambers"] += list(chamber_info)
	return data

/obj/machinery/computer/atmos_control/ui_act(action, params)
	. = ..()
	if(. || !control)
		return

	var/chamber = params["chamber"]
	if (!(chamber in atmos_chambers))
		return TRUE

	switch(action)
		if("toggle_input")
			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber]_in"]
			input?.on = !input.on
			input.update_appearance(UPDATE_ICON)
		if("toggle_output")
			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber]_out"]
			output?.on = !output.on
			output.update_appearance(UPDATE_ICON)
		if("adjust_input")
			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE
			target = clamp(target, 0, MAX_TRANSFER_RATE)

			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag["[chamber]_in"]
			input?.volume_rate = clamp(target, 0, min(input.airs[1].volume, MAX_TRANSFER_RATE))
		if("adjust_output")
			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag["[chamber]_out"]
			output?.internal_pressure_bound = clamp(target, 0, ATMOS_PUMP_MAX_PRESSURE)

	return TRUE

/obj/machinery/computer/atmos_control/nocontrol
	control = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/nocontrol

/// Vegetable
/obj/machinery/computer/atmos_control/fixed
	control = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/fixed
