// A freezer and a space heater had a baby.
/obj/machinery/space_heater/air_conditioner
	anchored = 0
	density = 1
	icon = 'icons/obj/atmos.dmi'
	icon_state = "aircond0"
	name = "air conditioner"
	desc = "If you can't take the heat, use one of these."
	set_temperature = 20		// in celcius, add T0C for kelvin
	var/cooling_power = 40000
	base_state = "aircond"

	light_color = LIGHT_COLOR_CYAN

	flags = FPRINT


/obj/machinery/space_heater/air_conditioner/New()
	..()
	cell = new(src)
	cell.charge = 1000
	cell.maxcharge = 1000
	update_icon()
	return

/obj/machinery/space_heater/air_conditioner/interact(mob/user as mob)
	if(panel_open)
		var/temp = set_temperature
		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
		else
			dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"


		dat += {"Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>
			Set Temperature:
			<A href='?src=\ref[src];op=temp;val=-5'>-</A>
			<A href='?src=\ref[src];op=temp;val=-1'>-</A>
			[temp]&deg;C
			<A href='?src=\ref[src];op=temp;val=1'>+</A>
			<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"}
		user.set_machine(src)
		user << browse("<HEAD><TITLE>Air Conditioner Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=aircond")
		onclose(user, "aircond")
	else
		on = !on
		user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
		update_icon()
	return


/obj/machinery/space_heater/air_conditioner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=aircond")
		usr.unset_machine()
		return 1
	else
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 0c and 25c(room temp)
				set_temperature = Clamp(set_temperature + value, 0, 25)

			if("cellremove")
				if(panel_open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
					cell = null
					usr.visible_message("<span class='notice'>[usr] removes the power cell from \the [src].</span>", "<span class='notice'>You remove the power cell from \the [src].</span>")


			if("cellinstall")
				if(panel_open && !cell)
					var/obj/item/weapon/cell/C = usr.get_active_hand()
					if(istype(C))
						if(usr.drop_item(C, src))
							cell = C
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

		src.updateDialog()
	return

/obj/machinery/space_heater/air_conditioner/proc/chill()
	var/turf/simulated/L = loc
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()
		var/transfer_moles = 0.25 * env.total_moles()
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		if(removed)
			if(removed.temperature > (set_temperature + T0C))
				var/air_heat_capacity = removed.heat_capacity()
				var/combined_heat_capacity = cooling_power + air_heat_capacity
				//var/old_temperature = removed.temperature

				if(combined_heat_capacity > 0)
					var/combined_energy = set_temperature*cooling_power + air_heat_capacity*removed.temperature
					removed.temperature = combined_energy/combined_heat_capacity
				env.merge(removed)
				return 1
			env.merge(removed)
	return 0

/obj/machinery/space_heater/air_conditioner/process()
	if(on)
		if(cell && cell.charge > 0)
			if(chill())
				cell.use(cooling_power/20000)
		else
			on = 0
			update_icon()
	return
