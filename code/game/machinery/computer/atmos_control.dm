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

	var/datum/netlink/datalink = null
	var/network_broadcast = NETWORK_ATMOS_CONTROL


/obj/machinery/air_sensor/setup_network()
	var/datum/component/ntnet_interface/conn = GetComponent(/datum/component/ntnet_interface)
	datalink = conn.register_port("status", list("gases" = list(),"temperature" = 0,"pressure" = 0, "timestamp" = 0, "id_tag" = id_tag))

/obj/machinery/air_sensor/atmos/toxin_tank
	name = "plasma tank gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_TOX
/obj/machinery/air_sensor/atmos/toxins_mixing_tank
	name = "toxins mixing gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB
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
/obj/machinery/air_sensor/atmos/incinerator_tank
	name = "incinerator chamber gas sensor"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_INCINERATOR

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"


/obj/machinery/air_sensor/process_atmos()
	if(on)
		if(datalink)
			var/datum/gas_mixture/air_sample = return_air()
			var/list/gasses = datalink.data["gases"]
			var/total_moles = air_sample.total_moles()

			if(total_moles)
				for(var/gas_id in air_sample.gases)
					var/gas_name = air_sample.gases[gas_id][GAS_META][META_GAS_NAME]
					gasses[gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

			datalink.data["pressure"] = air_sample.return_pressure()
			datalink.data["temperature"] = air_sample.temperature
			datalink.data["_updated"] = TRUE // always updated

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
	if(sensor_information)
		for(var/tag in sensor_information)
			qdel(sensor_information[tag])
		sensor_information = null
	return ..()

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	if(!sensor_information)
		var/datum/component/ntnet_interface/conn = GetComponent(/datum/component/ntnet_interface)
		// alright, we are assuming all the sensors are hooked up
		for(var/tag in sensors) // should throw a runtime here
			sensor_information[tag]	= conn.connect_port("status")

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole", name)
		ui.open()

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()
	data["sensors"] = list()
	for(var/tag in sensors)
		var/long_name = sensors[tag]
		var/datum/netlink/datalink = sensor_information[tag]
		if(!datalink)
			continue
		data["sensors"] += list(list(
			"id_tag"		= datalink.data["id_tag"],
			"long_name" 	= sanitize(long_name),
			"pressure"		= datalink.data["pressure"],
			"temperature"	= datalink.data["temperature"],
			"gases"			= datalink.data["gases"]
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
/obj/machinery/computer/atmos_control/tank/ui_interact(mob/user, datum/tgui/ui)
	var/datum/component/ntnet_interface/conn = null
	var/datum/component/ntnet_interface/target = null
	if(!input_info && input_tag)
		conn = GetComponent(/datum/component/ntnet_interface)
		target = conn.network.interface_find(input_tag)
		if(target)
			input_info = target.connect_port("status")
	if(!output_info && output_tag)
		if(!conn)
			conn = GetComponent(/datum/component/ntnet_interface)
		target = conn.network.interface_find(output_tag)
		if(target)
			output_info = target.connect_port("status")
	return ..()

/obj/machinery/computer/atmos_control/tank/ui_data(mob/user)
	var/list/data = ..()
	data["tank"] = TRUE
	if(input_info)
		data["inputting"] = input_info.data["power"]
		data["inputRate"] = input_info.data["volume_rate"]
	else
		data["inputting"] = 0
		data["inputRate"] = 0
	data["maxInputRate"] =  MAX_TRANSFER_RATE

	if(output_info)
		data["outputting"] = output_info["power"]
		data["outputPressure"] = output_info["internal"]
	else
		data["outputting"] = 0
		data["outputPressure"] = 0
	data["maxOutputPressure"] = MAX_OUTPUT_PRESSURE

	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("input")
			if(!input_info)
				to_chat(ui.user, "ERROR: No input connection for the terminal detected")
			else
				input_info.data["power"] = !input_info.data["power"]
				input_info.data["_updated"] = TRUE
			. = TRUE
		if("rate")
			if(!input_info)
				to_chat(ui.user, "ERROR: No input connection for the terminal detected")
			else
				var/target = text2num(params["rate"])
				if(target != null)
					input_info.data["volume_rate"] = clamp(target, 0, MAX_TRANSFER_RATE)
					input_info.data["_updated"] = TRUE
			. = TRUE
		if("output")
			if(!output_info)
				to_chat(ui.user, "ERROR: No output connection for the terminal detected")
			else
				output_info.data["power"] = !output_info.data["power"]
				output_info.data["_updated"] = TRUE
			. = TRUE
		if("pressure")
			if(!output_info)
				to_chat(ui.user, "ERROR: No output connection for the terminal detected")
			else
				var/target = text2num(params["pressure"])
				if(target != null)
					output_info.data["internal"] = clamp(target, 0, MAX_OUTPUT_PRESSURE)
					output_info.data["_updated"] = TRUE
			. = TRUE
