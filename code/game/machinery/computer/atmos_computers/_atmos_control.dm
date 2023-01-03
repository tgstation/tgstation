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
	/// Whether we are allowed to reconnect.
	var/reconnecting = TRUE

/// Reconnect only works for station based chambers.
/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	if(!reconnecting)
		return FALSE

	// We only prompt the user with the sensors that are actually available.
	var/available_devices = list()

	for (var/chamber_identifier in GLOB.station_gas_chambers)
		if (!(CHAMBER_INPUT_FROM_ID(chamber_identifier) in GLOB.objects_by_id_tag) && !(CHAMBER_OUTPUT_FROM_ID(chamber_identifier) in GLOB.objects_by_id_tag))
			continue

		available_devices[GLOB.station_gas_chambers[chamber_identifier]] = chamber_identifier

	// As long as we dont put any funny chars in the strings it should match.
	var/new_name = tgui_input_list(user, "Select the device set", "Reconnect", available_devices)
	var/new_id = available_devices[new_name]

	if(isnull(new_id))
		return FALSE

	atmos_chambers = list()
	atmos_chambers[new_id] = new_name

	name = new_name + (control ? " Control" : " Monitor")

	return TRUE

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
	data["reconnecting"] = reconnecting
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

		var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag[CHAMBER_INPUT_FROM_ID(chamber_id)]
		if (!isnull(input))
			chamber_info["input_info"] = list(
				"active" = input.on,
				"amount" = input.volume_rate,
			)

		var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[CHAMBER_OUTPUT_FROM_ID(chamber_id)]
		if (!isnull(output))
			chamber_info["output_info"] = list(
				"active" = output.on,
				"amount" = output.internal_pressure_bound,
			)

		data["chambers"] += list(chamber_info)
	return data

/obj/machinery/computer/atmos_control/ui_act(action, params)
	. = ..()
	if(. || !(control || reconnecting))
		return

	var/chamber = params["chamber"]

	switch(action)
		if("toggle_input")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/input = GLOB.objects_by_id_tag[CHAMBER_INPUT_FROM_ID(chamber)]
			input?.on = !input.on
			input.update_appearance(UPDATE_ICON)
		if("toggle_output")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[CHAMBER_OUTPUT_FROM_ID(chamber)]
			output?.on = !output.on
			output.update_appearance(UPDATE_ICON)
		if("adjust_input")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE
			target = clamp(target, 0, MAX_TRANSFER_RATE)

			var/obj/machinery/atmospherics/components/unary/outlet_injector/input = GLOB.objects_by_id_tag[CHAMBER_INPUT_FROM_ID(chamber)]
			input?.volume_rate = clamp(target, 0, min(input.airs[1].volume, MAX_TRANSFER_RATE))
		if("adjust_output")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[CHAMBER_OUTPUT_FROM_ID(chamber)]
			output?.internal_pressure_bound = clamp(target, 0, ATMOS_PUMP_MAX_PRESSURE)
		if("reconnect")
			reconnect(usr)

	return TRUE

/obj/machinery/computer/atmos_control/nocontrol
	control = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/nocontrol

/obj/machinery/computer/atmos_control/noreconnect
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/noreconnect

/// Vegetable
/obj/machinery/computer/atmos_control/fixed
	control = FALSE
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/fixed
