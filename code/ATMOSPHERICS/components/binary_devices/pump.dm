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

obj/machinery/atmospherics/binary/pump
	icon = 'icons/obj/atmospherics/pump.dmi'
	icon_state = "intact_off"

	name = "Gas pump"
	desc = "A pump"

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/*
	attack_hand(mob/user)
		on = !on
		update_icon()
*/

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

			if(network1)
				network1.update = 1

			if(network2)
				network2.update = 1

		return 1

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

		broadcast_status()
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

		interact(mob/user as mob)
			var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
						<b>Desirable output pressure: </b>
						[round(target_pressure,0.1)]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
						"}

			user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_pump")
			onclose(user, "atmo_pump")

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)

	receive_signal(datum/signal/signal)
		if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
			return 0

		if("power" in signal.data)
			on = text2num(signal.data["power"])

		if("power_toggle" in signal.data)
			on = !on

		if("set_output_pressure" in signal.data)
			target_pressure = between(
				0,
				text2num(signal.data["set_output_pressure"]),
				ONE_ATMOSPHERE*50
			)

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon

		spawn(2)
			broadcast_status()
		update_icon()
		return


	attack_hand(user as mob)
		if(..())
			return
		src.add_fingerprint(usr)
		if(!src.allowed(user))
			user << "\red Access denied."
			return
		usr.machine = src
		interact(user)
		return

	Topic(href,href_list)
		if(..()) return
		if(href_list["power"])
			on = !on
		if(href_list["set_press"])
			var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
			src.target_pressure = max(0, min(4500, new_pressure))
		usr.machine = src
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
