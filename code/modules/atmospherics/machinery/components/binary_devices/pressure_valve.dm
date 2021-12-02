/obj/machinery/atmospherics/components/binary/pressure_valve
	icon_state = "pvalve_map-3"
	name = "pressure valve"
	desc = "An activable one way valve that let gas pass through if the pressure on the input side is higher than the set pressure."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "pvalve"
	///Amount of pressure needed before the valve for it to open
	var/target_pressure = ONE_ATMOSPHERE
	///Frequency for radio signaling
	var/frequency = 0
	///ID for radio signaling
	var/id = null
	///Connection to the radio processing
	var/datum/radio_frequency/radio_connection
	///Check if the gas is moving from one pipenet to the other
	var/is_gas_flowing = FALSE

/obj/machinery/atmospherics/components/binary/pressure_valve/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/AltClick(mob/user)
	if(can_interact(user))
		target_pressure = MAX_OUTPUT_PRESSURE
		investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)
		balloon_alert(user, "target pressure set to [target_pressure] kPa")
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/Destroy()
	SSradio.remove_object(src,frequency)
	if(radio_connection)
		radio_connection = null
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/update_icon_nopipes()
	if(on && is_operational && is_gas_flowing)
		icon_state = "pvalve_flow-[set_overlay_offset(piping_layer)]"
	else if(on && is_operational && !is_gas_flowing)
		icon_state = "pvalve_on-[set_overlay_offset(piping_layer)]"
	else
		icon_state = "pvalve_off-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/pressure_valve/process_atmos()

	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	if(air1.return_pressure() > target_pressure)
		if(air1.release_gas_to(air2, air1.return_pressure()))
			update_parents()
			is_gas_flowing = TRUE
	else
		is_gas_flowing = FALSE
	update_icon_nopipes()

//Radio remote control

/**
 * Called in atmos_init(), used to change or remove the radio frequency from the component
 * Arguments:
 * * -new_frequency: the frequency that should be used for the radio to attach to the component, use 0 to remove the radio
 */
/obj/machinery/atmospherics/components/binary/pressure_valve/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/**
 * Called in atmos_init(), send the component status to the radio device connected
 */
/obj/machinery/atmospherics/components/binary/pressure_valve/proc/broadcast_status()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	))
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pressure_valve/relaymove(mob/living/user, direction)
	if(!on || direction != dir)
		return
	. = ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(ONE_ATMOSPHERE*100)
	return data

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = ONE_ATMOSPHERE*100
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, ONE_ATMOSPHERE*100)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance()

/obj/machinery/atmospherics/components/binary/pressure_valve/atmos_init()
	. = ..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pressure_valve/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*100)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if("status" in signal.data)
		broadcast_status()
		return

	broadcast_status()
	update_appearance()

/obj/machinery/atmospherics/components/binary/pressure_valve/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE


/obj/machinery/atmospherics/components/binary/pressure_valve/layer2
	piping_layer = 2
	icon_state= "pvalve_map-2"

/obj/machinery/atmospherics/components/binary/pressure_valve/layer4
	piping_layer = 4
	icon_state= "pvalve_map-4"

/obj/machinery/atmospherics/components/binary/pressure_valve/on
	on = TRUE
	icon_state = "pvalve_on_map-3"

/obj/machinery/atmospherics/components/binary/pressure_valve/on/layer2
	piping_layer = 2
	icon_state= "pvalve_on_map-2"

/obj/machinery/atmospherics/components/binary/pressure_valve/on/layer4
	piping_layer = 4
	icon_state= "pvalve_on_map-4"
