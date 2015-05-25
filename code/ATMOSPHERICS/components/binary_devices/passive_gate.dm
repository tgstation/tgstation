
/*

Passive gate is similar to the regular pump except:
* It doesn't require power
* Can not transfer low pressure to higher pressure (so it's more like a valve where you can control the flow)

*/

/obj/machinery/atmospherics/binary/passive_gate
	icon_state = "passgate_map"

	name = "passive gate"
	desc = "A one-way air valve that does not require power"

	can_unwrench = 1

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/passive_gate/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	..()

/obj/machinery/atmospherics/binary/passive_gate/update_icon_nopipes()
	overlays.Cut()
	if(on & !(stat & NOPOWER))
		overlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "passgate_on")

/obj/machinery/atmospherics/binary/passive_gate/process_atmos()
	..()
	if(!on)
		return 0

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return 1

	//Calculate necessary moles to transfer using PV = nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1


//Radio remote control

/obj/machinery/atmospherics/binary/passive_gate/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/passive_gate/proc/broadcast_status()
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

/obj/machinery/atmospherics/binary/passive_gate/ui_interact(mob/user, ui_key = "main")
	if(stat & (BROKEN|NOPOWER))
		return

	var/data = list()

	data["on"] = on
	data["pressure_set"] = round(target_pressure*100) //Nano UI can't handle rounded non-integers, apparently.
	data["max_pressure"] = MAX_OUTPUT_PRESSURE

	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, ui_key)
	if (!ui)
		ui = new /datum/nanoui(user, src, ui_key, "atmos_gas_pump.tmpl", name, 400, 120)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
	else
		ui.push_data(data)

/obj/machinery/atmospherics/binary/passive_gate/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = Clamp(
			text2num(signal.data["set_output_pressure"]),
			0,
			ONE_ATMOSPHERE*50
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
	return



/obj/machinery/atmospherics/binary/passive_gate/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		user << "<span class='danger'>Access denied.</span>"
		return
	usr.set_machine(src)
	ui_interact(user)
	return

/obj/machinery/atmospherics/binary/passive_gate/Topic(href,href_list)
	if(..()) return
	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
	if(href_list["set_press"])
		switch(href_list["set_press"])
			if ("max")
				target_pressure = MAX_OUTPUT_PRESSURE
			if ("set")
				target_pressure = max(0, min(MAX_OUTPUT_PRESSURE, safe_input("Pressure control", "Enter new output pressure (0-[MAX_OUTPUT_PRESSURE] kPa)", target_pressure)))
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/passive_gate/power_change()
	..()
	update_icon()



/obj/machinery/atmospherics/binary/passive_gate/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (on)
		user << "<span class='warning'>You cannot unwrench this [src], turn it off first!</span>"
		return 1
	return ..()
