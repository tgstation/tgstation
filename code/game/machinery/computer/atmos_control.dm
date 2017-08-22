/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gas tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	anchored = TRUE

	var/on = TRUE

	var/id_tag
	var/frequency = 1441
	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/update_icon()
		icon_state = "gsensor[on]"

/obj/machinery/air_sensor/process_atmos()
	if(on)
		var/datum/signal/signal = new
		var/datum/gas_mixture/air_sample = return_air()

		signal.transmission_method = 1 //radio signal
		signal.data = list(
			"sigtype" = "status",
			"id_tag" = id_tag,
			"timestamp" = world.time,
			"pressure" = air_sample.return_pressure(),
			"temperature" = air_sample.temperature,
			"gases" = list()
		)
		var/total_moles = air_sample.total_moles()
		if(total_moles)
			for(var/gas_id in air_sample.gases)
				var/gas_name = air_sample.gases[gas_id][GAS_META][META_GAS_NAME]
				signal.data["gases"][gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

		radio_connection.post_signal(src, signal, filter = GLOB.RADIO_ATMOSIA)


/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, GLOB.RADIO_ATMOSIA)

/obj/machinery/air_sensor/Initialize()
	..()
	SSair.atmos_machinery += src
	set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.atmos_machinery -= src
	SSradio.remove_object(src, frequency)
	return ..()

/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control
	name = "atmospherics monitoring"
	desc = "Used to monitor the station's atmospherics sensors."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control

	var/frequency = 1441
	var/list/sensors = list(
		"n2_sensor" = "Nitrogen Tank",
		"o2_sensor" = "Oxygen Tank",
		"co2_sensor" = "Carbon Dioxide Tank",
		"tox_sensor" = "Plasma Tank",
		"n2o_sensor" = "Nitrous Oxide Tank",
		"air_sensor" = "Mixed Air Tank",
		"mix_sensor" = "Mix Tank",
		"distro_meter" = "Distribution Loop",
		"waste_meter" = "Waste Loop",
	)
	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmos_control/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/computer/atmos_control/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/computer/atmos_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control", name, 400, 925, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()

	data["sensors"] = list()
	for(var/id_tag in sensors)
		var/long_name = sensors[id_tag]
		var/list/info = sensor_information[id_tag]
		if(!info)
			continue
		data["sensors"] += list(list(
			"id_tag"		= id_tag,
			"long_name" 	= sanitize(long_name),
			"pressure"		= info["pressure"],
			"temperature"	= info["temperature"],
			"gases"			= info["gases"]
		))
	return data

/obj/machinery/computer/atmos_control/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	var/id_tag = signal.data["id_tag"]
	if(!id_tag || !sensors.Find(id_tag))
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/atmos_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, GLOB.RADIO_ATMOSIA)

/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/tank
	var/input_tag
	var/output_tag
	frequency = 1441
	circuit = /obj/item/circuitboard/computer/atmos_control/tank

	var/list/input_info
	var/list/output_info

// This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
/obj/machinery/computer/atmos_control/tank/proc/reconnect(mob/user)
	var/list/IO = list()
	var/datum/radio_frequency/freq = SSradio.return_frequency(1441)
	var/list/devices = freq.devices["_default"]
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		var/list/text = splittext(U.id_tag, "_")
		IO |= text[1]
	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		var/list/text = splittext(U.id, "_")
		IO |= text[1]
	if(!IO.len)
		to_chat(user, "<span class='alert'>No machinery detected.</span>")
	var/S = input("Select the device set: ", "Selection", IO[1]) as anything in IO
	if(src)
		src.input_tag = "[S]_in"
		src.output_tag = "[S]_out"
		name = "[uppertext(S)] Supply Control"
		var/list/new_devices = freq.devices["4"]
		for(var/obj/machinery/air_sensor/U in new_devices)
			var/list/text = splittext(U.id_tag, "_")
			if(text[1] == S)
				sensors = list("[S]_sensor" = "Tank")
				break

	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		U.broadcast_status()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		U.broadcast_status()

/obj/machinery/computer/atmos_control/tank/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control", name, 500, 305, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_control/tank/ui_data(mob/user)
	var/list/data = ..()
	data["tank"] = TRUE
	data["inputting"] = input_info ? input_info["power"] : FALSE
	data["inputRate"] = input_info ? input_info["volume_rate"] : 0
	data["outputting"] = output_info ? output_info["power"] : FALSE
	data["outputPressure"] = output_info ? output_info["internal"] : 0

	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	if(..() || !radio_connection)
		return
	var/datum/signal/signal = new
	signal.transmission_method = 1
	signal.source = src
	signal.data = list("sigtype" = "command")
	switch(action)
		if("reconnect")
			reconnect(usr)
			. = TRUE
		if("input")
			signal.data += list("tag" = input_tag, "power_toggle" = TRUE)
			. = TRUE
		if("output")
			signal.data += list("tag" = output_tag, "power_toggle" = TRUE)
			. = TRUE
		if("pressure")
			var/target = input("New target pressure:", name, output_info ? output_info["internal"] : 0) as num|null
			if(!isnull(target) && !..())
				target =  Clamp(target, 0, 50 * ONE_ATMOSPHERE)
				signal.data += list("tag" = output_tag, "set_internal_pressure" = target)
				. = TRUE
	radio_connection.post_signal(src, signal, filter = GLOB.RADIO_ATMOSIA)

/obj/machinery/computer/atmos_control/tank/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)
