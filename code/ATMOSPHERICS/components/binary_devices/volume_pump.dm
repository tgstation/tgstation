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
	icon = 'icons/obj/atmospherics/volume_pump.dmi'
	icon_state = "intact_off"

	name = "Volumetric gas pump"
	desc = "A volumetric pump"

	var/on = 0
	var/transfer_rate = 200

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/volume_pump/on
	on = 1
	icon_state = "intact_on"

/obj/machinery/atmospherics/binary/volume_pump/update_icon(var/adjacent_procd)
	if(stat & NOPOWER)
		icon_state = "intact_off"
	else if(node1 && node2)
		icon_state = "intact_[on?("on"):("off")]"
	..()

/obj/machinery/atmospherics/binary/volume_pump/process()
	. = ..()
	if((stat & (NOPOWER|BROKEN)) || !on || transfer_rate < 1)
		return

// Pump mechanism just won't do anything if the pressure is too high/too low

	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)

	if(network1)
		network1.update = 1

	if(network2)
		network2.update = 1

	return 1

/obj/machinery/atmospherics/binary/volume_pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/atmospherics/binary/volume_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "APV",
		"power" = on,
		"transfer_rate" = transfer_rate,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/binary/volume_pump/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output flow: </b>
				[round(transfer_rate,1)]l/s | <a href='?src=\ref[src];set_transfer_rate=1'>Change</a>
				"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_pump")
	onclose(user, "atmo_pump")



/obj/machinery/atmospherics/binary/volume_pump/initialize()
	..()

	set_frequency(frequency)

/obj/machinery/atmospherics/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0
	var/old_on=on
	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_transfer_rate" in signal.data)
		transfer_rate = Clamp(text2num(signal.data["set_transfer_rate"]), 0, air1.volume)

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	if(old_on!=on)
		investigation_log(I_ATMOS,"was powered [on ? "on" : "off"] by a remote signal")


/obj/machinery/atmospherics/binary/volume_pump/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/volume_pump/Topic(href,href_list)
	if(..()) return
	if(href_list["power"])
		on = !on
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(usr)]")
	if(href_list["set_transfer_rate"])
		var/new_transfer_rate = input(usr,"Enter new output volume (0-200l/s)","Flow control",src.transfer_rate) as num
		src.transfer_rate = max(0, min(200, new_transfer_rate))
		investigation_log(I_ATMOS,"was set to [transfer_rate] L/s by [key_name(usr)]")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/volume_pump/power_change()
	..()
	update_icon()
