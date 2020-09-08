/obj/machinery/atmospherics/components/binary/pressure_valve
	icon_state = "pvalve_map-3"
	name = "pressure valve"
	desc = "An activable one way valve that let gas pass through if the pressure on the input side is higher than the set pressure."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

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
	///Max pressure allowed on other side of pump
	var/max_output_pressure = MAX_OUTPUT_PRESSURE
	///Number of stored springs inside the valve
	var/spring_numbers = 0
	///Max allowed number of springs in the valve
	var/max_springs = 5

	construction_type = /obj/item/pipe/directional
	pipe_state = "pvalve"

/obj/machinery/atmospherics/components/binary/pressure_valve/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/AltClick(mob/user)
	if(can_interact(user))
		target_pressure = max_output_pressure
		investigate_log("was set to [target_pressure] kPa by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/Destroy()
	SSradio.remove_object(src,frequency)
	if(radio_connection)
		radio_connection = null
	if(spring_numbers > 0)
		for(var/i in 1 to max_springs)
			new /obj/item/assembly/spring(loc)
	return ..()

/obj/machinery/atmospherics/components/binary/pressure_valve/examine(mob/user)
	. = ..()
	if(spring_numbers > 0)
		. += "<span class='notice'>The valve has installed [spring_numbers] [(spring_numbers == 1) ? "spring" : "springs"] that increase the max allowed pressure before the valve to [max_output_pressure] kpa!</span>"

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

/obj/machinery/atmospherics/components/binary/pressure_valve/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/spring))
		if(spring_numbers == max_springs)
			to_chat(user, "<span class='warning'>There are already [max_springs] connected to the valve!</span>")
			return TRUE
		spring_numbers++
		update_assembly()
		qdel(W)
		playsound(get_turf(src), 'sound/items/handling/component_pickup.ogg', 35, TRUE)
		return TRUE

/obj/machinery/atmospherics/components/binary/pressure_valve/proc/update_assembly()
	if(spring_numbers > 0)
		max_output_pressure = MAX_OUTPUT_PRESSURE //reset the pressure to the original one then adds up the new pressure
		var/spring_pressure_upgrade = 0
		for(var/i in 1 to spring_numbers)
			spring_pressure_upgrade += i/(max_springs * 2.45) * MAX_OUTPUT_PRESSURE
		max_output_pressure += spring_pressure_upgrade

/obj/machinery/atmospherics/components/binary/pressure_valve/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

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

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(max_output_pressure)
	return data

/obj/machinery/atmospherics/components/binary/pressure_valve/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = max_output_pressure
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, max_output_pressure)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/pressure_valve/atmosinit()
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
		target_pressure = clamp(text2num(signal.data["set_output_pressure"]),0,max_output_pressure)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if("status" in signal.data)
		broadcast_status()
		return

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/binary/pressure_valve/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
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
