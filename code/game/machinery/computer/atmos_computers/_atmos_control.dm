/// GENERAL AIR CONTROL (a.k.a atmos computer)
/obj/machinery/computer/atmos_control
	name = "atmospherics monitoring"
	desc = "Used to monitor the station's atmospherics sensors."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control
	light_color = LIGHT_COLOR_CYAN

	/// Which sensors do we want to listen to.
	/// Assoc of list[chamber_id] = readable_chamber_name
	var/list/atmos_chambers

	/// Used when control = FALSE to store the original atmos chambers so they dont get lost when reconnecting
	var/list/always_displayed_chambers

	/// Whether we can actually adjust the chambers or not.
	var/control = TRUE
	/// Whether we are allowed to reconnect.
	var/reconnecting = TRUE

	/// Was this computer multitooled before. If so copy the list connected_sensors as it now maintain's its own sensors independent of the map loaded one's
	var/was_multi_tooled = FALSE

	/// list of all sensors[key is chamber id, value is id of air sensor linked to this chamber] monitered by this computer
	var/list/connected_sensors

/obj/machinery/computer/atmos_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	var/static/list/multitool_tips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Link Sensor",
		)
	)
	AddElement(/datum/element/contextual_screentip_tools, multitool_tips)

	//all newly constructed/round start computers by default have access to this list
	connected_sensors = GLOB.map_loaded_sensors

	//special case for the station monitering console. We dont want to loose these chambers during reconnecting
	if(!control && !isnull(atmos_chambers))
		always_displayed_chambers = atmos_chambers.Copy()

/obj/machinery/computer/atmos_control/examine(mob/user)
	. = ..()
	. += span_notice("Use a multitool to link a air sensor to this computer")

/// Reconnect only works for station based chambers.
/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	if(!reconnecting)
		return FALSE

	// We only prompt the user with the sensors that are actually available.
	var/available_devices = list()

	for (var/chamber_identifier in connected_sensors)
		//this sensor was destroyed at the time of reconnecting
		var/obj/machinery/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber_identifier]]
		if(QDELETED(sensor))
			continue

		//non master computers don't have access to these station moniters. Only done to give master computer's special access to these chambers and make them feel special or something
		if(chamber_identifier == ATMOS_GAS_MONITOR_DISTRO)
			continue
		if(chamber_identifier == ATMOS_GAS_MONITOR_WASTE)
			continue

		available_devices[GLOB.station_gas_chambers[chamber_identifier]] = chamber_identifier

	// As long as we dont put any funny chars in the strings it should match.
	var/new_name = tgui_input_list(user, "Select the device set", "Reconnect", available_devices)
	if(isnull(new_name))
		return FALSE
	var/new_id = available_devices[new_name]
	if(isnull(new_id))
		return FALSE

	atmos_chambers = list()
	//these are chambers we always want to display even after reconnecting
	if(always_displayed_chambers)
		for(var/chamber_id in always_displayed_chambers)
			atmos_chambers[chamber_id] = always_displayed_chambers[chamber_id]
	atmos_chambers[new_id] = new_name

	name = new_name + (control ? " Control" : " Monitor")

	return TRUE

/obj/machinery/computer/atmos_control/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = ..()

	if(istype(multi_tool.buffer, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/sensor = multi_tool.buffer
		//computers reference a global map loaded list of sensor's but as soon a user attempt's to edit it, make a copy of that list so other computers aren't affected
		if(!was_multi_tooled)
			connected_sensors = connected_sensors.Copy()
			was_multi_tooled = TRUE
		//register the sensor's unique ID with its assositated chamber
		connected_sensors[sensor.chamber_id] = sensor.id_tag
		user.balloon_alert(user, "sensor connected to [src]")
		return ITEM_INTERACT_SUCCESS

	return

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

		var/obj/machinery/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber_id]]
		if(!QDELETED(sensor))
			chamber_info["gasmix"] = gas_mixture_parser(sensor.return_air())

		if(istype(sensor, /obj/machinery/air_sensor)) //distro & waste loop are not air sensors and don't have these functions
			var/obj/machinery/air_sensor/air_sensor = sensor

			var/obj/machinery/atmospherics/components/unary/outlet_injector/input = GLOB.objects_by_id_tag[air_sensor.inlet_id || ""]
			if (!QDELETED(input))
				chamber_info["input_info"] = list(
					"active" = input.on,
					"amount" = input.volume_rate,
				)

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[air_sensor.outlet_id || ""]
			if (!QDELETED(output))
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

			var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber]]
			if(QDELETED(sensor))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/outlet_injector/input = GLOB.objects_by_id_tag[sensor.inlet_id || ""]
			if(QDELETED(input))
				return TRUE

			input.on = !input.on
			input.update_appearance(UPDATE_ICON)
		if("toggle_output")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber]]
			if(QDELETED(sensor))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[sensor.outlet_id || ""]
			if(QDELETED(output))
				return TRUE

			output.on = !output.on
			output.update_appearance(UPDATE_ICON)
		if("adjust_input")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber]]
			if(QDELETED(sensor))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/outlet_injector/input = GLOB.objects_by_id_tag[sensor.inlet_id || ""]
			if(QDELETED(input))
				return TRUE

			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE
			target = clamp(target, 0, MAX_TRANSFER_RATE)

			input.volume_rate = clamp(target, 0, min(input.airs[1].volume, MAX_TRANSFER_RATE))
		if("adjust_output")
			if (!(chamber in atmos_chambers))
				return TRUE

			var/obj/machinery/air_sensor/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber]]
			if(QDELETED(sensor))
				return TRUE

			var/obj/machinery/atmospherics/components/unary/vent_pump/output = GLOB.objects_by_id_tag[sensor.outlet_id || ""]
			if(QDELETED(output))
				return TRUE

			var/target = text2num(params["rate"])
			if(isnull(target))
				return TRUE
			target = clamp(target, 0, ATMOS_PUMP_MAX_PRESSURE)

			output.internal_pressure_bound = target
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
