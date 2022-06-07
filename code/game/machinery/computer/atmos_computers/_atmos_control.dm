/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////
GLOBAL_LIST_EMPTY(atmos_air_controllers)

/obj/machinery/computer/atmos_control
	name = "atmospherics monitoring"
	desc = "Used to monitor the station's atmospherics sensors."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control
	light_color = LIGHT_COLOR_CYAN

	var/frequency = FREQ_ATMOS_STORAGE
	var/datum/radio_frequency/radio_connection

	/// Which sensors/input/outlets do we want to listen to.
	/// Assoc of list[chamber_id] = readable_chamber_name
	var/list/atmos_chambers

	// The list where received signals about devices are written into.
	// Assoc of list[atmos_chambers_string]
	var/list/sensor_info
	var/list/input_info
	var/list/output_info

	/// Whether we can actually adjust the chambers or not.
	var/control = TRUE
	/// Whether we are allowed to reconnect.
	var/reconnecting = TRUE

/obj/machinery/computer/atmos_control/Initialize(mapload)
	. = ..()

	GLOB.atmos_air_controllers += src
	set_frequency(frequency)

	sensor_info = list()
	input_info = list()
	output_info = list()

/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/computer/atmos_control/receive_signal(datum/signal/signal)
	if(!signal)
		return

	/// The tag of the signal data should be the id_tag var of the atmos object. Format is chamber_role.
	/// Where chamber is the chamber name and role is one of "sensor", "in", and "out".
	var/list/tag_data = splittext(signal.data["tag"], "_")

	if(length(tag_data) < 2)
		return

	if(!(tag_data[1] in atmos_chambers))
		return

	var/list/info_list
	switch(tag_data[2])
		if("sensor")
			info_list = sensor_info
		if("in")
			info_list = input_info
		if("out")
			info_list = output_info
		else
			return

	if(signal.data["sigtype"] == "status")
		info_list[tag_data[1]] = signal.data

	if(signal.data["sigtype"] == "destroyed")
		info_list[tag_data[1]] = null

/obj/machinery/computer/atmos_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

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
		if(sensor_info[chamber_id])
			chamber_info["gasmix"] = sensor_info[chamber_id]["gasmix"]
		if(input_info[chamber_id])
			chamber_info["input_info"] = list()
			chamber_info["input_info"]["active"] = input_info[chamber_id]["power"]
			chamber_info["input_info"]["amount"] = input_info[chamber_id]["volume_rate"]
		if(output_info[chamber_id])
			chamber_info["output_info"] = list()
			chamber_info["output_info"]["active"] = output_info[chamber_id]["power"]
			chamber_info["output_info"]["amount"] = output_info[chamber_id]["internal"]
		data["chambers"] += list(chamber_info)
	return data

/obj/machinery/computer/atmos_control/ui_act(action, params)
	. = ..()
	if(. || !radio_connection || !(control || reconnecting))
		return

	var/datum/signal/signal = new(list("sigtype" = "command", "user" = usr))
	switch(action)
		if("reconnect")
			return reconnect(usr)
		if("toggle_input")
			if(!(params["chamber"] in atmos_chambers))
				return FALSE
			signal.data += list("tag" = params["chamber"] + "_in", "power_toggle" = TRUE)
		if("toggle_output")
			if(!(params["chamber"] in atmos_chambers))
				return FALSE
			signal.data += list("tag" = params["chamber"] + "_out", "power_toggle" = TRUE)
		if("adjust_input")
			if(!(params["chamber"] in atmos_chambers))
				return FALSE
			var/target = text2num(params["rate"])
			if(isnull(target))
				return FALSE
			target = clamp(target, 0, MAX_TRANSFER_RATE)
			signal.data += list("tag" = params["chamber"] + "_in", "set_volume_rate" = target)
		if("adjust_output")
			if(!(params["chamber"] in atmos_chambers))
				return FALSE
			var/target = text2num(params["rate"])
			if(isnull(target))
				return FALSE
			target = clamp(target, 0, MAX_OUTPUT_PRESSURE)
			signal.data += list("tag" = params["chamber"] + "_out", "set_internal_pressure" = target)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
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
