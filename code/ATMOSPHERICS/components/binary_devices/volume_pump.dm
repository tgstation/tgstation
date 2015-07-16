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

/obj/machinery/atmospherics/binary/volume_pump
	icon_state = "volpump_map"
	name = "volumetric gas pump"
	desc = "A volumetric pump"

	can_unwrench = 1

	var/on = 0
	var/transfer_rate = MAX_TRANSFER_RATE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/volume_pump/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/obj/machinery/atmospherics/binary/volume_pump/on
	on = 1

/obj/machinery/atmospherics/binary/volume_pump/update_icon_nopipes()
	if(stat & NOPOWER)
		icon_state = "volpump_off"
		return

	icon_state = "volpump_[on?"on":"off"]"

/obj/machinery/atmospherics/binary/volume_pump/process_atmos()
//	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!on)
		return 0

// Pump mechanism just won't do anything if the pressure is too high/too low

	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return 1

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)

	parent1.update = 1

	parent2.update = 1

	return 1

/obj/machinery/atmospherics/binary/volume_pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/atmospherics/binary/volume_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "APV",
		"power" = on,
		"transfer_rate" = transfer_rate,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/binary/volume_pump/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return

	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "atmos_gas_pump.tmpl", name, 400, 120, 0)

/obj/machinery/atmospherics/binary/volume_pump/get_ui_data()
	var/data = list()
	data["on"] = on
	data["transfer_rate"] = round(transfer_rate*100) //Nano UI can't handle rounded non-integers, apparently.
	data["max_rate"] = MAX_TRANSFER_RATE
	return data

/obj/machinery/atmospherics/binary/volume_pump/atmosinit()
	..()

	set_frequency(frequency)

/obj/machinery/atmospherics/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_transfer_rate" in signal.data)
		transfer_rate = Clamp(
			text2num(signal.data["set_transfer_rate"]),
			0,
			air1.volume
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()


/obj/machinery/atmospherics/binary/volume_pump/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		user << "<span class='danger'>Access denied.</span>"
		return
	usr.set_machine(src)
	ui_interact(user)
	return

/obj/machinery/atmospherics/binary/volume_pump/Topic(href,href_list)
	if(..()) return
	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
	if(href_list["set_transfer_rate"])
		switch(href_list["set_transfer_rate"])
			if ("max")
				transfer_rate = MAX_TRANSFER_RATE
			if ("set")
				transfer_rate = max(0, min(MAX_TRANSFER_RATE, safe_input("Pressure control", "Enter new transfer rate (0-[MAX_TRANSFER_RATE] L/s)", transfer_rate)))
		investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", "atmos")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/volume_pump/power_change()
	..()
	update_icon()



/obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/weapon/W, mob/user, params)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!(stat & NOPOWER) && on)
		user << "<span class='warning'>You cannot unwrench this [src], turn it off first!</span>"
		return 1
	return ..()
