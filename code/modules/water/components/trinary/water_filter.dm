obj/machinery/water/trinary/filter
	icon = 'filter.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Liquid filter"

	req_access = list(access_atmospherics)

	var/on = 0
	var/temp = null // -- TLE

	var/target_pressure = ONE_ATMOSPHERE

	var/list/filter_types = list()
	var/filter_types_text

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

	New()
		if(filter_types_text)
			filter_types = dd_text2list(filter_types_text, ";")
			filter_types_text = null

		if(radio_controller)
			initialize()
		..()

	update_icon()
		if(node2 && node3 && node1)
			icon_state = "intact_[on?("on"):("off")]"
		else
			icon_state = "hintact_off"
			on = 0

		return

	New()
		..()

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = return_pressure3()

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary volume to transfer

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_vol = pressure_delta * r3.maximum_volume / max_pressure

		//Actually transfer the reagents

		if(transfer_vol > 0)
			var/datum/reagents/removed = new(transfer_vol)
			removed.my_atom = src
			r1.trans_to(removed, transfer_vol)

			var/datum/reagents/filtered_out = new(transfer_vol)
			filtered_out.my_atom = src

			// transfer each type in filter list
			for(var/T in filter_types)
				var/datum/reagent/R = removed.has_reagent(T)
				if(!R) continue
				filtered_out.add_reagent(T, R.volume)
				removed.remove_reagent(T, R.volume)

			filtered_out.trans_to(r2, filtered_out.total_volume)
			removed.trans_to(r3, removed.total_volume)

		if(network2)
			network2.update = 1
		else if(r2.total_volume > 0)	// leak out 1->2
			mingle_dc2_with_turf()

		if(network3)
			network3.update = 1
		else if(r3.total_volume > 0)	// leak out 1->3
			mingle_dc3_with_turf()

		if(network1)
			network1.update = 1

		return 1

	hide(var/i)
		if(level == 1 && istype(loc, /turf/simulated))
			invisibility = i ? 101 : 0
		update_icon()

	initialize()
		set_frequency(frequency)
		..()
		var/turf/T = src.loc	// hide if turf is not intact
		hide(T.intact)

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((return_pressure1()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
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


obj/machinery/water/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		user << "\red Access denied."
		return

	var/dat
	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b><a href='?src=\ref[src];add=1'>Add</a><hr>"}

	for(var/T in filter_types)
		dat += "<a href='?src=\ref[src];remove=[T]'>[T]</a><br>"

	dat += {"<HR><B>Desirable output pressure:</B>
			[src.target_pressure] | <a href='?src=\ref[src];set_press=1'>Change</a>
			"}
/*
		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return

	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
*/
	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")
	return

obj/machinery/water/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if (href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["power"])
		on=!on
	if(href_list["add"])
		var/list/choices = new()
		for(var/T in typesof(/datum/reagent) - /datum/reagent)
			var/datum/reagent/R = new T()
			choices += R.id
		var/choice = input("Choose Reagent", name) in choices
		filter_types += choice
	if(href_list["remove"])
		filter_types -= href_list["remove"]
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return


