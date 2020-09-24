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
	var/datum/netlink/datalink
	var/network_broadcast = NETWORK_ATMOS_CONTROL

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
		if(!datalink)
			var/datum/component/ntnet_interface/interface = GetComponent(/datum/component/ntnet_interface)
			var/list/status_cache = list()
			status_cache["gases"] = list()
			datalink = interface.regester_port("status",status_cache)

		var/datum/gas_mixture/air_sample = return_air()
		var/list/gasses = datalink["gases"]

		var/total_moles = air_sample.total_moles()
		if(total_moles)
			for(var/gas_id in air_sample.gases)
				var/gas_name = air_sample.gases[gas_id][GAS_META][META_GAS_NAME]
				gasses[gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

		datalink["id_tag"] = network_tag
		datalink["timestamp"] = world.time
		datalink["pressure"] = air_sample.return_pressure()
		datalink["temperature"] = air_sample.temperature

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


/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	for(var/tag in sensor_information)
		qdel(sensor_information[tag])
	sensor_information = null
	return ..()

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	if(!sensor_information)
		sensor_information = list()
		var/datum/component/ntnet_interface/conn = GetComponent(/datum/component/ntnet_interface)
		var/datum/component/ntnet_interface/other
		// alright, we are assuming all the sensors are hooked up
		for(var/tag in sensors) // should throw a runtime here
			other = conn.network.get_interface(tag)
			sensor_information[tag]	= other.connect_port("status")

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole", name)
		ui.open()

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()

	data["sensors"] = list()
	for(var/tag in  sensors)
		var/long_name = sensors[tag]
		var/list/info = sensor_information[tag]
		if(!info)
			continue
		data["sensors"] += list(list(
			"id_tag"		= tag,
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
	var/datum/netlink/input_info
	var/datum/netlink/output_info

/obj/machinery/computer/atmos_control/tank/proc/check_connection()
	var/datum/component/ntnet_interface/my_conn
	if(!input_info && input_tag)
		my_conn = GetComponent(/datum/component/ntnet_interface)
		var/datum/component/ntnet_interface/input_conn = my_conn.network.get_interface(input_tag)
		if(!input_conn)
			debug_world_log("Input tag [input_tag] for [name] does not exist")
			input_tag = null // deleted so it dosn't show up again
			return
		input_info = input_conn.connect_port("status")
		if(!input_info)
			debug_world_log("Input tag [input_tag] for [name] port 'status' does not exist'")
			input_tag = null
			return
	if(!output_info && output_tag)
		my_conn = GetComponent(/datum/component/ntnet_interface)
		var/datum/component/ntnet_interface/output_conn = my_conn.network.get_interface(output_tag)
		if(!output_conn)
			debug_world_log("Output tag [output_tag] for [name] does not exist")
			input_tag = null // deleted so it dosn't show up again
			return
		output_info = output_conn.connect_port("status")
		if(!output_info)
			debug_world_log("Output tag [output_tag] for [name] port 'status' does not exist'")
			input_tag = null
			return

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
	check_connection()
	var/list/data = ..()
	data["tank"] = TRUE
	data["inputting"] = input_info ? input_info["power"] : FALSE
	data["inputRate"] = input_info ? input_info["volume_rate"] : FALSE
	data["outputting"] = output_info ? output_info["power"] : FALSE
	data["outputPressure"] = output_info ? output_info["internal"] : FALSE
	return data

/obj/machinery/computer/atmos_control/tank/proc/send_update(tag, list/data)
	data["sigtype"] = "command"
	data["tag"] = tag
	var/datum/component/ntnet_interface/my_conn = GetComponent(/datum/component/ntnet_interface)
	var/datum/netdata/signal = new(data)
	signal.receiver_id = tag
	signal.receiver_network = my_conn.network.network_id
	ntnet_send(signal)

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("update_output")
			var/hid = params["hid"]
			var/datum/component/ntnet_interface/I = SSnetworks.lookup_interface(hid)
			if(!istype(I, /obj/machinery/atmospherics/components/unary/vent_pump))
				to_chat(usr,"Device not found or invalid for vent pump")
			else
				output_tag = hid
				output_info = null // reconnected on next update
				. = TRUE
		if("update_input")
			var/hid = params["hid"]
			var/datum/component/ntnet_interface/I = SSnetworks.lookup_interface(hid)
			if(!istype(I, /obj/machinery/atmospherics/components/unary/outlet_injector))
				to_chat(usr,"Device not found or invalid for input injector")
			else
				input_tag = hid
				input_info = null // reconnected on next update
				. = TRUE
		if("input")
			send_update(input_tag, list("power_toggle" = TRUE))
			. = TRUE
		if("rate")
			var/target = text2num(params["rate"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_TRANSFER_RATE)
				send_update(input_tag, list("set_volume_rate" = target))
				. = TRUE
		if("output")
			send_update(output_tag, list("power_toggle" = TRUE))
			. = TRUE
		if("pressure")
			var/target = text2num(params["pressure"])
			if(!isnull(target))
				target = clamp(target, 0, 4500)
				send_update(output_tag, list("set_internal_pressure" = target))
				. = TRUE


