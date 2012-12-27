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

obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/obj/atmospherics/volume_pump.dmi'
	icon_state = "intact_off"

	name = "Volumetric gas pump"
	desc = "A volumetric pump"

	var/on = 0
	var/transfer_rate = 200

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	on
		on = 1
		icon_state = "intact_on"

	update_icon()
		if(node1&&node2)
			icon_state = "intact_[on?("on"):("off")]"
		else
			if(node1)
				icon_state = "exposed_1_off"
			else if(node2)
				icon_state = "exposed_2_off"
			else
				icon_state = "exposed_3_off"
		return

	process()
//		..()
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

		if(network1)
			network1.update = 1

		if(network2)
			network2.update = 1

		return 1

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency)

		broadcast_status()
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

		interact(mob/user as mob)
			var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
						<b>Desirable output flow: </b>
						[round(transfer_rate,1)]l/s | <a href='?src=\ref[src];set_transfer_rate=1'>Change</a>
						"}

			user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_pump")
			onclose(user, "atmo_pump")



	initialize()
		..()

		set_frequency(frequency)

	receive_signal(datum/signal/signal)
		if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
			return 0

		if("power" in signal.data)
			on = text2num(signal.data["power"])

		if("power_toggle" in signal.data)
			on = !on

		if("set_transfer_rate" in signal.data)
			transfer_rate = between(
				0,
				text2num(signal.data["set_transfer_rate"]),
				air1.volume
			)

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon

		spawn(2)
			broadcast_status()
		update_icon()


	attack_hand(user as mob)
		if(..())
			return
		src.add_fingerprint(usr)
		if(!src.allowed(user))
			user << "\red Access denied."
			return
		usr.set_machine(src)
		interact(user)
		return

	Topic(href,href_list)
		if(..()) return
		if(href_list["power"])
			on = !on
		if(href_list["set_transfer_rate"])
			var/new_transfer_rate = input(usr,"Enter new output volume (0-200l/s)","Flow control",src.transfer_rate) as num
			src.transfer_rate = max(0, min(200, new_transfer_rate))
		usr.set_machine(src)
		src.update_icon()
		src.updateUsrDialog()
		return

	power_change()
		..()
		update_icon()



	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (!(stat & NOPOWER) && on)
			user << "\red You cannot unwrench this [src], turn it off first."
			return 1
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)

