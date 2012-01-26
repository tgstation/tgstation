obj/machinery/water/trinary/mixer
	icon = 'mixer.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Liquid mixer"

	req_access = list(access_atmospherics)

	var/on = 0

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

	update_icon()
		if(node2 && node3 && node1)
			icon_state = "intact_[on?("on"):("off")]"
		else
			icon_state = "intact_off"
			on = 0

		return

	New()
		..()
		r3.maximum_volume = 500

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = return_pressure3()

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_vol1 = (node1_concentration*pressure_delta) * r1.maximum_volume / max_pressure
		var/transfer_vol2 = (node2_concentration*pressure_delta) * r2.maximum_volume / max_pressure

		var/r1_vol = r1.total_volume
		var/r2_vol = r2.total_volume

		if((r1_vol < transfer_vol1) || (r2_vol < transfer_vol2))
			if(!transfer_vol1 || !transfer_vol2) return
			var/ratio = min(r1_vol/transfer_vol1, r2_vol/transfer_vol2)

			transfer_vol1 *= ratio
			transfer_vol2 *= ratio

		//Actually transfer the gas

		if(transfer_vol1 > 0)
			r1.trans_to(r3, transfer_vol1)

		if(transfer_vol2 > 0)
			r2.trans_to(r3, transfer_vol2)

		if(network1 && transfer_vol1)
			network1.update = 1

		if(network2 && transfer_vol2)
			network2.update = 1

		if(network3)
			network3.update = 1
		else if(r3.total_volume > 0)	// leak out 1,2->3
			mingle_dc3_with_turf()

		return 1

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((return_pressure3()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/water_pipe(loc, make_from=src)
			del(src)

	attack_hand(user as mob)
		if(..())
			return
		src.add_fingerprint(usr)
		if(!src.allowed(user))
			user << "\red Access denied."
			return
		usr.machine = src
		var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
					<b>Desirable output pressure: </b>
					[target_pressure]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
					<br>
					<b>Node 1 Concentration:</b>
					<a href='?src=\ref[src];node1_c=-0.1'><b>-</b></a>
					<a href='?src=\ref[src];node1_c=-0.01'>-</a>
					[node1_concentration]([node1_concentration*100]%)
					<a href='?src=\ref[src];node1_c=0.01'><b>+</b></a>
					<a href='?src=\ref[src];node1_c=0.1'>+</a>
					<br>
					<b>Node 2 Concentration:</b>
					<a href='?src=\ref[src];node2_c=-0.1'><b>-</b></a>
					<a href='?src=\ref[src];node2_c=-0.01'>-</a>
					[node2_concentration]([node2_concentration*100]%)
					<a href='?src=\ref[src];node2_c=0.01'><b>+</b></a>
					<a href='?src=\ref[src];node2_c=0.1'>+</a>
					"}

		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_mixer")
		onclose(user, "atmo_mixer")
		return

	Topic(href,href_list)
		if(href_list["power"])
			on = !on
		if(href_list["set_press"])
			var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
			src.target_pressure = max(0, min(4500, new_pressure))
		if(href_list["node1_c"])
			var/value = text2num(href_list["node1_c"])
			src.node1_concentration = max(0, min(1, src.node1_concentration + value))
			src.node2_concentration = max(0, min(1, src.node2_concentration - value))
		if(href_list["node2_c"])
			var/value = text2num(href_list["node2_c"])
			src.node2_concentration = max(0, min(1, src.node2_concentration + value))
			src.node1_concentration = max(0, min(1, src.node1_concentration - value))
		src.update_icon()
		src.updateUsrDialog()
		return
