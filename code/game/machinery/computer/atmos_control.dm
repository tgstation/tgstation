/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gas tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE
	network_id = NETWORK_ATMOS_STORAGE
	var/list/status_cache
	var/network_broadcast = NETWORK_ATMOS_CONTROL

/obj/machinery/air_sensor/NetworkInitialize()
	var/datum/component/ntnet_interface/interface = GetComponent(/datum/component/ntnet_interface)
	status_cache = list()
	status_cache["gases"] = list()
	interface.regester_port("status",status_cache)

/obj/machinery/air_sensor/atmos/toxin_tank
	name = "plasma tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_TOX
/obj/machinery/air_sensor/atmos/toxins_mixing_tank
	name = "toxins mixing gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB
/obj/machinery/air_sensor/atmos/oxygen_tank
	name = "oxygen tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_O2
/obj/machinery/air_sensor/atmos/nitrogen_tank
	name = "nitrogen tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_N2
/obj/machinery/air_sensor/atmos/mix_tank
	name = "mix tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_MIX
/obj/machinery/air_sensor/atmos/nitrous_tank
	name = "nitrous oxide tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_N2O
/obj/machinery/air_sensor/atmos/air_tank
	name = "air mix tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_AIR
/obj/machinery/air_sensor/atmos/carbon_tank
	name = "carbon dioxide tank gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_CO2
/obj/machinery/air_sensor/atmos/incinerator_tank
	name = "incinerator chamber gas sensor"
	network_tag = ATMOS_GAS_MONITOR_SENSOR_INCINERATOR

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"


/obj/machinery/air_sensor/process_atmos()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()
		var/list/gasses = status_cache["gases"]

		var/total_moles = air_sample.total_moles()
		if(total_moles)
			for(var/gas_id in air_sample.gases)
				var/gas_name = air_sample.gases[gas_id][GAS_META][META_GAS_NAME]
				gasses[gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

		status_cache["id_tag"] = network_tag
		status_cache["timestamp"] = world.time
		status_cache["pressure"] = air_sample.return_pressure()
		status_cache["temperature"] = air_sample.temperature

/obj/machinery/air_sensor/Initialize()
	. = ..()
	SSair.start_processing_machine(src)

/obj/machinery/air_sensor/Destroy()
	SSair.stop_processing_machine(src)

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

	var/list/sensors = list(
		ATMOS_GAS_MONITOR_SENSOR_N2 = "Nitrogen Tank",
		ATMOS_GAS_MONITOR_SENSOR_O2 = "Oxygen Tank",
		ATMOS_GAS_MONITOR_SENSOR_CO2 = "Carbon Dioxide Tank",
		ATMOS_GAS_MONITOR_SENSOR_TOX = "Plasma Tank",
		ATMOS_GAS_MONITOR_SENSOR_N2O = "Nitrous Oxide Tank",
		ATMOS_GAS_MONITOR_SENSOR_AIR = "Mixed Air Tank",
		ATMOS_GAS_MONITOR_SENSOR_MIX = "Mix Tank",
		ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION = "Distribution Loop",
		ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE = "Atmos Waste Loop",
		ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Incinerator Chamber",
		ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB = "Toxins Mixing Chamber"
	)
	var/list/sensor_information = list()
	network_id = NETWORK_ATMOS_CONTROL

/obj/machinery/computer/atmos_control/Initialize()
	. = ..()
	GLOB.atmos_air_controllers += src


/obj/machinery/computer/atmos_control/NetworkInitialize()
	// alright, we are assuming all the sensors are hooked up
	for(var/tag in sensors) // should throw a runtime here
		sensor_information[tag]	= SSnetworks.connect_port(tag, "status")

/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	for(var/tag in sensor_information)
		qdel(sensor_information[tag])
	sensor_information = null
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
			"id_tag"		= id_tag,
			"long_name" 	= sanitize(long_name),
			"pressure"		= info["pressure"],
			"temperature"	= info["temperature"],
			"gases"			= info["gases"]
		))
	return data


//Incinerator sensor only
/obj/machinery/computer/atmos_control/incinerator
	name = "Incinerator Air Control"
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Incinerator Chamber")
	circuit = /obj/item/circuitboard/computer/atmos_control/incinerator

//Toxins mix sensor only
/obj/machinery/computer/atmos_control/toxinsmix
	name = "Toxins Mixing Air Control"
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB = "Toxins Mixing Chamber")
	circuit = /obj/item/circuitboard/computer/atmos_control/toxinsmix

/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/tank
	var/input_tag
	var/output_tag
	var/input_hid
	var/output_hid
	var/datum/netlink/input_info
	var/datum/netlink/output_info

/obj/machinery/computer/atmos_control/tank/NetworkInitialize()
	if(input_tag)
		input_hid = SSnetworks.network_tag_to_hardware_id[input_tag]
		ASSERT(input_hid !=null)
		input_info = SSnetworks.connect_port(input_tag, "status")
	if(output_tag)
		output_hid = SSnetworks.network_tag_to_hardware_id[output_hid]
		ASSERT(output_hid !=null)
		output_info = SSnetworks.connect_port(output_tag, "status")

/obj/machinery/computer/atmos_control/tank/oxygen_tank
	name = "Oxygen Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_O2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_O2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_O2 = "Oxygen Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank

/obj/machinery/computer/atmos_control/tank/toxin_tank
	name = "Plasma Supply Control"
	input_tag = ATMOS_GAS_MONITOR_INPUT_TOX
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_TOX
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_TOX = "Plasma Tank")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/toxin_tank

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

// This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
// WarlockD - Not a hacky madness anymore!  If the user knows the hid address, it will just connect

/obj/machinery/computer/atmos_control/tank/ui_data(mob/user)
	var/list/data = ..()
	data["tank"] = TRUE
	data["inputting"] = input_info ? input_info["power"] : 0
	data["inputRate"] = input_info ? input_info["volume_rate"] : 0
	data["maxInputRate"] = input_info ? MAX_TRANSFER_RATE : 0
	data["outputting"] = output_info ? output_info["power"] : 0
	data["outputPressure"] = output_info ? output_info["internal"] : 0
	data["maxOutputPressure"] = output_info ? MAX_OUTPUT_PRESSURE : 0
	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	if(..())
		return
	var/datum/netdata/signal = new(list("sigtype" = "command", "user" = usr))
	signal.receiver_network = NETWORK_ATMOS_STORAGE
	switch(action)
		if("update_output")
			var/hid = params["hid"]
			var/datum/component/ntnet_interface/I = SSnetworks.lookup_interface(hid)
			if(!istype(I, /obj/machinery/atmospherics/components/unary/vent_pump))
				to_chat(usr,"Device not found or invalid for vent pump")
			else
				output_info = I.connect_port("status")
				. = TRUE
		if("update_input")
			var/hid = params["hid"]
			var/datum/component/ntnet_interface/I = SSnetworks.lookup_interface(hid)
			if(!istype(I, /obj/machinery/atmospherics/components/unary/outlet_injector))
				to_chat(usr,"Device not found or invalid for input injector")
			else
				input_info = I.connect_port("status")
				. = TRUE
		if("input")
			signal.data += list("tag" = input_tag, "power_toggle" = TRUE)
			signal.receiver_id = input_tag
			. = TRUE
		if("rate")
			var/target = text2num(params["rate"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_TRANSFER_RATE)
				signal.data += list("tag" = input_tag, "set_volume_rate" = target)
				signal.receiver_id = input_tag
				. = TRUE
		if("output")
			signal.data += list("tag" = output_tag, "power_toggle" = TRUE)
			signal.receiver_id = output_tag
			. = TRUE
		if("pressure")
			var/target = text2num(params["pressure"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_OUTPUT_PRESSURE)
				signal.data += list("tag" = output_tag, "set_internal_pressure" = target)
				signal.receiver_id = output_tag
				. = TRUE
	ntnet_send(signal)

