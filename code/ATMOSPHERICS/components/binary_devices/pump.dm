/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/components/binary/pump
	icon_state = "pump_map"
	name = "gas pump"
	desc = "A pump"

	can_unwrench = 1

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/components/binary/pump/Destroy()
	if(SSradio)
		SSradio.remove_object(src,frequency)
	if(radio_connection)
		radio_connection = null
	return ..()
/obj/machinery/atmospherics/components/binary/pump/on
	on = 1

/obj/machinery/atmospherics/components/binary/pump/update_icon_nopipes()
	if(stat & NOPOWER)
		icon_state = "pump_off"
		return

	icon_state = "pump_[on?"on":"off"]"

/obj/machinery/atmospherics/components/binary/pump/process_atmos()
//	..()
	if(stat & (NOPOWER|BROKEN))
		return 0
	if(!on)
		return 0

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/output_starting_pressure = air2.return_pressure()

	if( (target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return 1

	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		update_parents()

	return 1

//Radio remote control
/obj/machinery/atmospherics/components/binary/pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/components/binary/pump/interact(mob/user)
	if(stat & (BROKEN|NOPOWER)) return
	if(!src.allowed(usr))
		usr << "<span class='danger'>Access denied.</span>"
		return
	ui_interact(user)

/obj/machinery/atmospherics/components/binary/pump/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
	if (!ui)
		ui = new(user, src, ui_key, "atmos_pump", name, 400, 115)
		ui.open()

/obj/machinery/atmospherics/components/binary/pump/get_ui_data()
	var/data = list()
	data["on"] = on
	data["set_pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	return data

/obj/machinery/atmospherics/components/binary/pump/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = Clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*50)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	return


/obj/machinery/atmospherics/components/binary/pump/attack_hand(mob/user)
	if(..() || !user)
		return
	interact(user)

/obj/machinery/atmospherics/components/binary/pump/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
		if("pressure")
			switch(params["set"])
				if ("max")
					target_pressure = MAX_OUTPUT_PRESSURE
				if ("custom")
					target_pressure = max(0, min(MAX_OUTPUT_PRESSURE, safe_input("Pressure control", "Enter new output pressure (0-[MAX_OUTPUT_PRESSURE] kPa)", target_pressure)))
			investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")
	update_icon()
	return 1

/obj/machinery/atmospherics/components/binary/pump/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/attackby(obj/item/weapon/W, mob/user, params)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		user << "<span class='warning'>You cannot unwrench this [src], turn it off first!</span>"
		return 1
	return ..()

