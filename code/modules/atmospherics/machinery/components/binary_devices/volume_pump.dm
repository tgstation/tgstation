// Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.
//
// node1, air1, network1 correspond to input
// node2, air2, network2 correspond to output
//
// Thus, the two variables affect pump operation are set in New():
//   air1.volume
//     This is the volume of gas available to the pump that may be transfered to the output
//   air2.volume
//     Higher quantities of this cause more air to be perfected later
//     but overall network volume is also increased as this increases...

/obj/machinery/atmospherics/components/binary/volume_pump
	icon_state = "volpump_map-3"
	name = "volumetric gas pump"
	desc = "A pump that moves gas by volume."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	var/transfer_rate = MAX_TRANSFER_RATE
	var/overclocked = FALSE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/directional
	pipe_state = "volumepump"
	///Max pressure allowed on other side of pump
	var/max_output_pressure = 9000
	///Number of stored motors inside the pump
	var/motor_numbers = 0
	///Max allowed number of motors in the pump
	var/max_motors = 5

/obj/machinery/atmospherics/components/binary/volume_pump/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/volume_pump/AltClick(mob/user)
	if(can_interact(user))
		transfer_rate = MAX_TRANSFER_RATE
		investigate_log("was set to [transfer_rate] L/s by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/volume_pump/Destroy()
	SSradio.remove_object(src,frequency)
	if(motor_numbers > 0)
		for(var/i in 1 to max_motors)
			new /obj/item/assembly/motor(loc)
	return ..()

/obj/machinery/atmospherics/components/binary/volume_pump/update_icon_nopipes()
	icon_state = on && is_operational ? "volpump_on-[set_overlay_offset(piping_layer)]" : "volpump_off-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/volume_pump/process_atmos(delta_time)
//	..()
	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

// Pump mechanism just won't do anything if the pressure is too high/too low unless you overclock it.

	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || ((output_starting_pressure > max_output_pressure)) && !overclocked)
		return

	if(overclocked && (output_starting_pressure-input_starting_pressure > 1000))//Overclocked pumps can only force gas a certain amount.
		return


	var/transfer_ratio = (transfer_rate * delta_time) / air1.volume

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	if(overclocked)//Some of the gas from the mixture leaks to the environment when overclocked
		var/turf/open/T = loc
		if(istype(T))
			var/datum/gas_mixture/leaked = removed.remove_ratio(DT_PROB_RATE(VOLUME_PUMP_LEAK_AMOUNT, delta_time))
			T.assume_air(leaked)
			T.air_update_turf()

	air2.merge(removed)

	update_parents()

/obj/machinery/atmospherics/components/binary/volume_pump/examine(mob/user)
	. = ..()
	if(overclocked)
		. += "Its warning light is on[on ? " and it's spewing gas!" : "."]"
	if(motor_numbers > 0)
		. += "<span class='notice'>The pump has installed [motor_numbers] [(motor_numbers == 1) ? "motor" : "motors"] that increase the max output to [max_output_pressure] kpa!</span>"

/obj/machinery/atmospherics/components/binary/volume_pump/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/motor))
		if(motor_numbers == max_motors)
			to_chat(user, "<span class='warning'>There are already [max_motors] connected to the pump!</span>")
			return TRUE
		motor_numbers++
		update_assembly()
		qdel(W)
		var/obj/item/assembly/motor/motor = W
		playsound(get_turf(src), motor.pickup_sound, 35, TRUE)
		return TRUE

/obj/machinery/atmospherics/components/binary/volume_pump/proc/update_assembly()
	if(motor_numbers > 0)
		max_output_pressure = 9000 //reset the pressure to the original one then adds up the new pressure
		var/motor_pressure_upgrade = 0
		for(var/i in 1 to motor_numbers)
			motor_pressure_upgrade += i/(max_motors * 3) * 9000
		max_output_pressure += motor_pressure_upgrade
		use_power += 250

/obj/machinery/atmospherics/components/binary/volume_pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency)

/obj/machinery/atmospherics/components/binary/volume_pump/proc/broadcast_status()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list(
		"tag" = id,
		"device" = "APV",
		"power" = on,
		"transfer_rate" = transfer_rate,
		"sigtype" = "status"
	))
	radio_connection.post_signal(src, signal)

/obj/machinery/atmospherics/components/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/volume_pump/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(transfer_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)
	return data

/obj/machinery/atmospherics/components/binary/volume_pump/atmosinit()
	..()

	set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/volume_pump/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = MAX_TRANSFER_RATE
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				transfer_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
				investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_transfer_rate" in signal.data)
		var/datum/gas_mixture/air1 = airs[1]
		transfer_rate = clamp(text2num(signal.data["set_transfer_rate"]),0,air1.volume)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/binary/volume_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/binary/volume_pump/multitool_act(mob/living/user, obj/item/I)
	if(!overclocked)
		overclocked = TRUE
		to_chat(user, "The pump makes a grinding noise and air starts to hiss out as you disable its pressure limits.")
	else
		overclocked = FALSE
		to_chat(user, "The pump quiets down as you turn its limiters back on.")
	return TRUE

// mapping

/obj/machinery/atmospherics/components/binary/volume_pump/layer2
	piping_layer = 2
	icon_state = "volpump_map-2"

/obj/machinery/atmospherics/components/binary/volume_pump/layer2
	piping_layer = 2
	icon_state = "volpump_map-2"

/obj/machinery/atmospherics/components/binary/volume_pump/on
	on = TRUE
	icon_state = "volpump_on_map"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer2
	piping_layer = 2
	icon_state = "volpump_map-2"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer4
	piping_layer = 4
	icon_state = "volpump_map-4"
