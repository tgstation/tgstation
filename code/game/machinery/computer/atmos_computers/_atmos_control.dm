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
	var/list/atmos_chambers = list()
	/// list of all sensors[key is chamber id, value is id of air sensor linked to this chamber] monitered by this computer
	var/list/connected_sensors = list()
	/// Whether we can actually adjust the chambers or not.
	var/control = TRUE
	/// Whether we are allowed to reconnect.
	var/reconnecting = TRUE
	///OUur last reconnected chamber
	VAR_PRIVATE/last_chamber_id = ""

/obj/machinery/computer/atmos_control/post_machine_initialize()
	. = ..()

	scan()

///Scans the z level for new air sensors & monitors
/obj/machinery/computer/atmos_control/proc/scan()
	PRIVATE_PROC(TRUE)

	//collect all sensors that are the closest to this computer
	var/list/closest_sensors = list()
	var/turf/comp_turf = get_turf(src)
	for(var/obj/machinery/sensor as anything in (SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/air_sensor) + SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/meter/monitored)))
		//same z level
		if(sensor.z != z)
			continue
		//infer chamber id
		var/chamber_id = ""
		if(istype(sensor, /obj/machinery/air_sensor))
			var/obj/machinery/air_sensor/air_sense = sensor
			chamber_id = air_sense.chamber_id
		else
			var/obj/machinery/meter/monitored/meter = sensor
			chamber_id = meter.chamber_id
		//track & collect closest sensors
		if(!closest_sensors[chamber_id])
			closest_sensors[chamber_id] = sensor
			continue
		var/obj/machinery/target = closest_sensors[chamber_id]
		if(get_dist(comp_turf, get_turf(sensor)) < get_dist(comp_turf, get_turf(target)))
			closest_sensors[chamber_id] = sensor
	//convert sensor list to id tags
	connected_sensors.Cut()
	for(var/chamber_id in closest_sensors)
		var/obj/machinery/target = closest_sensors[chamber_id]
		connected_sensors[chamber_id] = target.id_tag

/// Reconnect only works for station based chambers.
/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	if(!reconnecting)
		return FALSE

	scan()

	// We only prompt the user with the sensors that are actually available.
	var/available_devices = list()
	for (var/chamber_identifier in connected_sensors)
		//this sensor was destroyed at the time of reconnecting
		var/obj/machinery/sensor = GLOB.objects_by_id_tag[connected_sensors[chamber_identifier]]
		if(QDELETED(sensor))
			connected_sensors -= chamber_identifier
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

	atmos_chambers -= last_chamber_id
	atmos_chambers[new_id] = new_name
	last_chamber_id = new_id

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

/obj/machinery/computer/atmos_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
			return TRUE

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
			return TRUE

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
			return TRUE

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
			return TRUE

		if("reconnect")
			reconnect(ui.user)
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
