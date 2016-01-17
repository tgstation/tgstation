/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gas tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	name = "gas sensor"
	anchored = 1

	var/on = 1
	var/state = 0

	var/id_tag
	var/frequency = 1439

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
		for(var/gas_id in air_sample.gases)
			var/gas_name = air_sample.gases[gas_id][GAS_NAME]
			signal.data["gases"][gas_name] = air_sample.gases[gas_id][MOLES] / total_moles * 100

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/initialize()
	set_frequency(frequency)

/obj/machinery/air_sensor/New()
	..()
	SSair.atmos_machinery += src
	if(SSradio)
		set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.atmos_machinery -= src
	if(SSradio)
		SSradio.remove_object(src,frequency)
	return ..()

/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/weapon/circuitboard/atmos_control

	var/frequency = 1439
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

/obj/machinery/computer/atmos_control/New()
	..()
	if(SSradio)
		set_frequency(frequency)

/obj/machinery/computer/atmos_control/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/computer/atmos_control/attack_hand(mob/user)
	interact(user)

/obj/machinery/computer/atmos_control/interact(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmos_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control", name, 500, 750, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_control/get_ui_data(mob/user)
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
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["id_tag"]
	if(!id_tag || !sensors.Find(id_tag)) return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/atmos_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_control/initialize()
	set_frequency(frequency)

/obj/machinery/computer/atmos_control/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("initialize")
			if(name != initial(name))
				return
			switch(params["type"])
				if("dist")
					name = "Distribution and Waste Monitor"
					set_frequency(1443)
					sensors = list(
						"air_in_meter" = "Mixed Air In",
						"air_sensor" = "Mixed Air Supply Tank",
						"air_out_meter" = "Mixed Air Out",
						"distro_meter" = "Distribution Loop",
						"waste_meter" = "Waste Loop"
					)
				if("tank")
					name = "Tank Monitor"
					set_frequency(1441)
					sensors = list(
						"n2_sensor" = "Nitrogen",
						"o2_sensor" = "Oxygen",
						"co2_sensor" = "Carbon Dioxide",
						"tox_sensor" = "Toxins",
						"n2o_sensor" = "Nitrous Oxide",
						"mix_sensor" = "Mix"
					)
	return 1


/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/tank
	var/input_tag
	var/output_tag
	frequency = 1441
	circuit = /obj/item/weapon/circuitboard/atmos_control/tank

	var/list/input_info
	var/list/output_info

// This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
/obj/machinery/computer/atmos_control/tank/proc/reconnect(mob/user)
	var/list/IO = list()
	var/datum/radio_frequency/air_freq = SSradio.return_frequency(1443)
	var/datum/radio_frequency/gas_freq = SSradio.return_frequency(1441)
	var/list/devices = air_freq.devices["_default"]
	devices |= gas_freq.devices["_default"]
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		var/list/text = text2list(U.id_tag, "_")
		IO |= text[1]
	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		var/list/text = text2list(U.id, "_")
		IO |= text[1]
	if(!IO.len)
		user << "<span class='alert'>No machinery detected.</span>"
	var/S = input("Select the device set: ", "Selection", IO[1]) as anything in IO
	if(src)
		src.input_tag = "[S]_in"
		src.output_tag = "[S]_out"
		name = "[uppertext(S)] Supply Control"
		var/list/new_devices = gas_freq.devices["4"]
		new_devices |= air_freq.devices["4"]
		for(var/obj/machinery/air_sensor/U in new_devices)
			var/list/text = text2list(U.id_tag, "_")
			if(text[1] == S)
				sensors = list("[S]_sensor" = "Tank")
				break

	if(S == "air")
		frequency = 1443
	else
		frequency = 1441

	set_frequency(frequency)

	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		U.broadcast_status()

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		U.broadcast_status()

/obj/machinery/computer/atmos_control/tank/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_control/tank", name, 400, 425, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_control/tank/get_ui_data(mob/user)
	var/list/data = ..(user)
	data["inputting"] = input_info ? input_info["power"] : FALSE
	data["inputRate"] = input_info ? input_info["volume_rate"] : 0
	data["outputting"] = output_info ? output_info["power"] : FALSE
	data["outputPressure"] = output_info ? output_info["internal"] : 0

	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1
	signal.source = src
	signal.data = list("sigtype" = "command")

	switch(action)
		if("reconnect")
			reconnect(usr)
		if("input")
			signal.data += list("tag" = input_tag, "power_toggle" = TRUE)
		if("output")
			signal.data += list("tag" = output_tag, "power_toggle" = TRUE)
		if("output_pressure")
			var/custom = input(usr, "Adjust output pressure:", name) as null|num
			if(isnum(custom))
				var/pressure = Clamp(custom, 0, 50 * ONE_ATMOSPHERE)
				signal.data += list("tag" = output_tag, "set_internal_pressure" = "[pressure]")

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
	return 1

/obj/machinery/computer/atmos_control/tank/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)
