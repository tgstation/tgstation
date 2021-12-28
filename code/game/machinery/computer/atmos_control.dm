/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gas tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE

	var/frequency = FREQ_ATMOS_STORAGE
	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/atmos/plasma_tank
	name = "plasma tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_PLAS
/obj/machinery/air_sensor/atmos/ordnance_mixing_tank
	name = "ordnance mixing gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_ORDNANCE_LAB
/obj/machinery/air_sensor/atmos/oxygen_tank
	name = "oxygen tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_O2
/obj/machinery/air_sensor/atmos/nitrogen_tank
	name = "nitrogen tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_N2
/obj/machinery/air_sensor/atmos/mix_tank
	name = "mix tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_MIX
/obj/machinery/air_sensor/atmos/nitrous_tank
	name = "nitrous oxide tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_N2O
/obj/machinery/air_sensor/atmos/air_tank
	name = "air mix tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_AIR
/obj/machinery/air_sensor/atmos/carbon_tank
	name = "carbon dioxide tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_CO2
/obj/machinery/air_sensor/atmos/bz_tank
	name = "bz tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_BZ
/obj/machinery/air_sensor/atmos/freon_tank
	name = "freon tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_FREON
/obj/machinery/air_sensor/atmos/halon_tank
	name = "halon tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_HALON
/obj/machinery/air_sensor/atmos/healium_tank
	name = "healium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_HEALIUM
/obj/machinery/air_sensor/atmos/hydrogen_tank
	name = "hydrogen tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_H2
/obj/machinery/air_sensor/atmos/hypernoblium_tank
	name = "hypernoblium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_HYPERNOBLIUM
/obj/machinery/air_sensor/atmos/miasma_tank
	name = "miasma tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_MIASMA
/obj/machinery/air_sensor/atmos/nitrium_tank
	name = "nitrium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_NITRIUM
/obj/machinery/air_sensor/atmos/pluoxium_tank
	name = "pluoxium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_PLUOXIUM
/obj/machinery/air_sensor/atmos/proto_nitrate_tank
	name = "proto-nitrate tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_PROTO_NITRATE
/obj/machinery/air_sensor/atmos/tritium_tank
	name = "tritium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_TRITIUM
/obj/machinery/air_sensor/atmos/water_vapor_tank
	name = "water vapor tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_H2O
/obj/machinery/air_sensor/atmos/zauker_tank
	name = "zauker tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_ZAUKER
/obj/machinery/air_sensor/atmos/helium_tank
	name = "helium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_HELIUM
/obj/machinery/air_sensor/atmos/antinoblium_tank
	name = "antinoblium tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_ANTINOBLIUM
/obj/machinery/air_sensor/atmos/incinerator_tank
	name = "incinerator chamber gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_INCINERATOR

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/process_atmos()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()

		var/datum/signal/signal = new(list(
			"sigtype" = "status",
			"id_tag" = id_tag,
			"timestamp" = world.time,
			"pressure" = air_sample.return_pressure(),
			"temperature" = air_sample.temperature,
			"gases" = list()
		))
		var/total_moles = air_sample.total_moles()
		if(total_moles)
			for(var/gas_id in air_sample.gases)
				var/gas_name = air_sample.gases[gas_id][GAS_META][META_GAS_NAME]
				signal.data["gases"][gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.stop_processing_machine(src)
	SSradio.remove_object(src, frequency)
	return ..()

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
	var/list/sensors = list(
		ATMOS_GAS_MONITOR_SENSOR_N2 = "Nitrogen Tank",
		ATMOS_GAS_MONITOR_SENSOR_O2 = "Oxygen Tank",
		ATMOS_GAS_MONITOR_SENSOR_CO2 = "Carbon Dioxide Tank",
		ATMOS_GAS_MONITOR_SENSOR_PLAS = "Plasma Tank",
		ATMOS_GAS_MONITOR_SENSOR_N2O = "Nitrous Oxide Tank",
		ATMOS_GAS_MONITOR_SENSOR_AIR = "Mixed Air Tank",
		ATMOS_GAS_MONITOR_SENSOR_MIX = "Mix Tank",
		ATMOS_GAS_MONITOR_SENSOR_BZ = "BZ Tank",
		ATMOS_GAS_MONITOR_SENSOR_FREON = "Freon Tank",
		ATMOS_GAS_MONITOR_SENSOR_HALON = "Halon Tank",
		ATMOS_GAS_MONITOR_SENSOR_HEALIUM = "Healium Tank",
		ATMOS_GAS_MONITOR_SENSOR_H2 = "Hydrogen Tank",
		ATMOS_GAS_MONITOR_SENSOR_HYPERNOBLIUM = "Hypernoblium Tank",
		ATMOS_GAS_MONITOR_SENSOR_MIASMA = "Miasma Tank",
		ATMOS_GAS_MONITOR_SENSOR_NITRIUM = "Nitrium Tank",
		ATMOS_GAS_MONITOR_SENSOR_PLUOXIUM = "Pluoxium Tank",
		ATMOS_GAS_MONITOR_SENSOR_PROTO_NITRATE = "Proto-Nitrate Tank",
		ATMOS_GAS_MONITOR_SENSOR_TRITIUM = "Tritium Tank",
		ATMOS_GAS_MONITOR_SENSOR_H2O = "Water Vapor Tank",
		ATMOS_GAS_MONITOR_SENSOR_ZAUKER = "Zauker Tank",
		ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION = "Distribution Loop",
		ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE = "Atmos Waste Loop",
		ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Incinerator Chamber",
		ATMOS_GAS_MONITOR_SENSOR_ORDNANCE_LAB = "Ordnance Mixing Chamber"
	)
	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection


/obj/machinery/computer/atmos_control/Initialize(mapload)
	. = ..()
	GLOB.atmos_air_controllers += src
	set_frequency(frequency)

/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole", name)
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
			"id_tag" = id_tag,
			"long_name" = sanitize(long_name),
			"pressure" = info["pressure"],
			"temperature" = info["temperature"],
			"gases" = info["gases"]
		))
	return data

/obj/machinery/computer/atmos_control/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["id_tag"]
	if(!id_tag || !sensors.Find(id_tag))
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/atmos_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

//Incinerator sensor only
/obj/machinery/computer/atmos_control/incinerator
	name = "Incinerator Air Control"
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Incinerator Chamber")
	circuit = /obj/item/circuitboard/computer/atmos_control/incinerator

//Ordnance mix sensor only
/obj/machinery/computer/atmos_control/ordnancemix
	name = "Ordnance Mixing Air Control"
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_ORDNANCE_LAB = "Ordnance Mixing Chamber")
	circuit = /obj/item/circuitboard/computer/atmos_control/ordnancemix

/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/tank
	var/input_tag
	var/output_tag
	frequency = FREQ_ATMOS_STORAGE
	circuit = /obj/item/circuitboard/computer/atmos_control/tank
	var/list/input_info
	var/list/output_info

/obj/machinery/computer/atmos_control/tank/oxygen_tank
	name = "Oxygen Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_O2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_O2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_O2 = "Oxygen Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank

/obj/machinery/computer/atmos_control/tank/plasma_tank
	name = "Plasma Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_PLAS
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_PLAS
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_PLAS = "Plasma Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/plasma_tank

/obj/machinery/computer/atmos_control/tank/air_tank
	name = "Mixed Air Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_AIR
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_AIR
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_AIR = "Air Mix Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/air_tank

/obj/machinery/computer/atmos_control/tank/mix_tank
	name = "Gas Mix Tank Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_MIX
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_MIX
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_MIX = "Gas Mix Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/mix_tank

/obj/machinery/computer/atmos_control/tank/nitrous_tank
	name = "Nitrous Oxide Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_N2O
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_N2O
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_N2O = "Nitrous Oxide Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank

/obj/machinery/computer/atmos_control/tank/nitrogen_tank
	name = "Nitrogen Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_N2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_N2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_N2 = "Nitrogen Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank

/obj/machinery/computer/atmos_control/tank/carbon_tank
	name = "Carbon Dioxide Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_CO2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_CO2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_CO2 = "Carbon Dioxide Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/carbon_tank

/obj/machinery/computer/atmos_control/tank/bz_tank
	name = "BZ Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_BZ
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_BZ
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_BZ = "BZ Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/bz_tank

/obj/machinery/computer/atmos_control/tank/freon_tank
	name = "Freon Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_FREON
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_FREON
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_FREON = "Freon Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/freon_tank

/obj/machinery/computer/atmos_control/tank/halon_tank
	name = "Halon Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_HALON
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_HALON
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_HALON = "Halon Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/halon_tank

/obj/machinery/computer/atmos_control/tank/healium_tank
	name = "Healium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_HEALIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_HEALIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_HEALIUM = "Healium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/healium_tank

/obj/machinery/computer/atmos_control/tank/hydrogen_tank
	name = "Hydrogen Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_H2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_H2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_H2 = "Hydrogen Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/hydrogen_tank

/obj/machinery/computer/atmos_control/tank/hypernoblium_tank
	name = "Hypernoblium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_HYPERNOBLIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_HYPERNOBLIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_HYPERNOBLIUM = "Hypernoblium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/hypernoblium_tank

/obj/machinery/computer/atmos_control/tank/miasma_tank
	name = "Miasma Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_MIASMA
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_MIASMA
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_MIASMA = "Miasma Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/miasma_tank

/obj/machinery/computer/atmos_control/tank/nitrium_tank
	name = "Nitrium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_NITRIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_NITRIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_NITRIUM = "Nitrium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nitrium_tank

/obj/machinery/computer/atmos_control/tank/pluoxium_tank
	name = "Pluoxium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_PLUOXIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_PLUOXIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_PLUOXIUM = "Pluoxium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/pluoxium_tank

/obj/machinery/computer/atmos_control/tank/proto_nitrate_tank
	name = "Proto-Nitrate Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_PROTO_NITRATE
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_PROTO_NITRATE
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_PROTO_NITRATE = "Proto-Nitrate Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/proto_nitrate_tank

/obj/machinery/computer/atmos_control/tank/tritium_tank
	name = "Tritium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_TRITIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_TRITIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_TRITIUM = "Tritium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/tritium_tank

/obj/machinery/computer/atmos_control/tank/water_vapor
	name = "Water Vapor Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_H2O
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_H2O
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_H2O = "Water Vapor Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/water_vapor

/obj/machinery/computer/atmos_control/tank/zauker_tank
	name = "Zauker Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_ZAUKER
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_ZAUKER
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_ZAUKER = "Zauker Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/zauker_tank

/obj/machinery/computer/atmos_control/tank/helium_tank
	name = "Helium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_HELIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_HELIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_HELIUM = "Helium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/helium_tank

/obj/machinery/computer/atmos_control/tank/antinoblium_tank
	name = "Antinoblium Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_ANTINOBLIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_ANTINOBLIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_ANTINOBLIUM = "Antinoblium Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/antinoblium_tank

// This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
/obj/machinery/computer/atmos_control/tank/proc/reconnect(mob/user)
	var/list/IO = list()
	var/datum/radio_frequency/freq = SSradio.return_frequency(frequency)

	var/list/devices = list()
	var/list/device_refs = freq.devices["_default"]
	for(var/datum/weakref/device_ref as anything in device_refs)
		var/atom/device = device_ref.resolve()
		if(!device)
			device_refs -= device_ref
			continue
		devices += device

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		var/list/text = splittext(U.id_tag, "_")
		IO |= text[1]
	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		var/list/text = splittext(U.id, "_")
		IO |= text[1]
	if(!IO.len)
		to_chat(user, span_alert("No machinery detected."))
	var/S = tgui_input_list(user, "Select the device set", "Reconnect", sort_list(IO))
	if(isnull(S))
		return
	if(src)
		src.input_tag = "[S]_in"
		src.output_tag = "[S]_out"
		name = "[uppertext(S)] Supply Control"
		var/list/new_devices = freq.devices["atmosia"]
		sensors.Cut()
		for(var/obj/machinery/air_sensor/U in new_devices)
			var/list/text = splittext(U.id_tag, "_")
			if(text[1] == S)
				sensors = list("[S]_sensor" = "[S] Tank")
				break

	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		U.broadcast_status()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		U.broadcast_status()

/obj/machinery/computer/atmos_control/tank/ui_data(mob/user)
	var/list/data = ..()
	data["tank"] = TRUE
	data["inputting"] = input_info ? input_info["power"] : FALSE
	data["inputRate"] = input_info ? input_info["volume_rate"] : 0
	data["maxInputRate"] = input_info ? MAX_TRANSFER_RATE : 0
	data["outputting"] = output_info ? output_info["power"] : FALSE
	data["outputPressure"] = output_info ? output_info["internal"] : 0
	data["maxOutputPressure"] = output_info ? MAX_OUTPUT_PRESSURE : 0
	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	. = ..()

	if(. || !radio_connection)
		return
	var/datum/signal/signal = new(list("sigtype" = "command", "user" = usr))
	switch(action)
		if("reconnect")
			reconnect(usr)
			. = TRUE
		if("input")
			signal.data += list("tag" = input_tag, "power_toggle" = TRUE)
			. = TRUE
		if("rate")
			var/target = text2num(params["rate"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_TRANSFER_RATE)
				signal.data += list("tag" = input_tag, "set_volume_rate" = target)
				. = TRUE
		if("output")
			signal.data += list("tag" = output_tag, "power_toggle" = TRUE)
			. = TRUE
		if("pressure")
			var/target = text2num(params["pressure"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_OUTPUT_PRESSURE)
				signal.data += list("tag" = output_tag, "set_internal_pressure" = target)
				. = TRUE
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/computer/atmos_control/tank/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)
