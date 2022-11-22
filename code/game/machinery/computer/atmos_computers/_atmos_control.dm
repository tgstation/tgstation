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

/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	SSradio.remove_object(src, frequency)
	return ..()

/// Reconnect only works for station based chambers.
/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	if(!reconnecting)
		return FALSE

	// We only prompt the user with the sensors that are actually available.
	var/available_devices = list()
	for(var/datum/weakref/device_ref as anything in radio_connection.devices[RADIO_ATMOSIA])
		var/obj/machinery/machine = device_ref.resolve()
		if(istype(machine, /obj/machinery/computer/atmos_control)) // Skip if we are a listener. Make this a list if you add devices that work similarly to this comp.
			continue
		var/chamber_identifier = splittext(machine.id_tag, "_")[1]
		if(!GLOB.station_gas_chambers[chamber_identifier])
			continue
		available_devices[GLOB.station_gas_chambers[chamber_identifier]] = chamber_identifier

	// As long as we dont put any funny chars in the strings it should match.
	var/new_name = tgui_input_list(user, "Select the device set", "Reconnect", available_devices)
	var/new_id = available_devices[new_name]

	if(isnull(new_id))
		return FALSE

	atmos_chambers = list()
	atmos_chambers[new_id] = new_name
	sensor_info = list()
	input_info = list()
	output_info = list()

	name = new_name + (control ? " Control" : " Monitor")

	// Ask things around us to update.
	// Due to how signal datums work this is unoptimized but as long as our freq isnt terribly populated we should be fine.
	// Also, we dont need to prompt sensors and meters since they already broadcast every process_atmos().
	var/datum/signal/update_request = new(list("sigtype" = "command", "user" = usr, "status" = TRUE ,"tag" = "[new_id]_in"))
	radio_connection.post_signal(src, update_request, filter = RADIO_ATMOSIA)
	update_request = new(list("sigtype" = "command", "user" = usr, "status" = TRUE ,"tag" = "[new_id]_out"))
	radio_connection.post_signal(src, update_request, filter = RADIO_ATMOSIA)

	return TRUE
#endif

/obj/machinery/computer/atmos_control/proc/reconnect(mob/user)
	// MBTODO: Reconnect

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
	if(. || !(control || reconnecting))
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

/obj/machinery/computer/atmos_control/noreconnect
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/noreconnect

/// Vegetable
/obj/machinery/computer/atmos_control/fixed
	control = FALSE
	reconnecting = FALSE
	circuit = /obj/item/circuitboard/computer/atmos_control/fixed
