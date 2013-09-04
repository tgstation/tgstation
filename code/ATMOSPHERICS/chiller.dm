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

	flags = FPRINT


/obj/machinery/space_heater/air_conditioner/New()
	..()
	cell = new(src)
	cell.charge = 1000
	cell.maxcharge = 1000
	update_icon()
	return

/obj/machinery/space_heater/air_conditioner/update_icon()
	overlays.Cut()
	icon_state = "aircond[on]"
	if(open)
		overlays  += "sheater-open"
	return

/obj/machinery/space_heater/air_conditioner/examine()
	set src in oview(12)
	if (!( usr ))
		return
	usr << "This is \icon[src] \an [src.name]."
	usr << src.desc

	usr << "The air conditioner is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
	if(open)
		usr << "The power cell is [cell ? "installed" : "missing"]."
	else
		usr << "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"
	return

/obj/machinery/space_heater/air_conditioner/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/air_conditioner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/cell))
		if(open)
			if(cell)
				user << "There is already a power cell inside."
				return
			else
				// insert cell
				var/obj/item/weapon/cell/C = usr.get_active_hand()
				if(istype(C))
					user.drop_item()
					cell = C
					C.loc = src
					C.add_fingerprint(usr)

					user.visible_message("\blue [user] inserts a power cell into [src].", "\blue You insert the power cell into [src].")
		else
			user << "The hatch must be open to insert a power cell."
			return
	else if(istype(I, /obj/item/weapon/screwdriver))
		open = !open
		user.visible_message("\blue [user] [open ? "opens" : "closes"] the hatch on the [src].", "\blue You [open ? "open" : "close"] the hatch on the [src].")
		update_icon()
		if(!open && user.machine == src)
			user << browse(null, "window=aircond")
			user.unset_machine()
	else
		..()
	return
/obj/machinery/space_heater/air_conditioner/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/air_conditioner/interact(mob/user as mob)
	if(open)
		var/temp = set_temperature
		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
		else
			dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\ATMOSPHERICS\chiller.dm:95: dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"
		dat += {"Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>
			Set Temperature: 
			<A href='?src=\ref[src];op=temp;val=-5'>-</A> 
			<A href='?src=\ref[src];op=temp;val=-1'>-</A>
			[temp]&deg;C 
			<A href='?src=\ref[src];op=temp;val=1'>+</A> 
			<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"}
		// END AUTOFIX
		user.set_machine(src)
		user << browse("<HEAD><TITLE>Air Conditioner Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=aircond")
		onclose(user, "aircond")
	else
		on = !on
		user.visible_message("\blue [user] switches [on ? "on" : "off"] the [src].","\blue You switch [on ? "on" : "off"] the [src].")
		update_icon()
	return


/obj/machinery/space_heater/air_conditioner/Topic(href, href_list)
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 15c and 20c(room temp)
				set_temperature = dd_range(15, 25, set_temperature + value)

			if("cellremove")
				if(open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
					cell = null
					usr.visible_message("\blue [usr] removes the power cell from \the [src].", "\blue You remove the power cell from \the [src].")


			if("cellinstall")
				if(open && !cell)
					var/obj/item/weapon/cell/C = usr.get_active_hand()
					if(istype(C))
						usr.drop_item()
						cell = C
						C.loc = src
						C.add_fingerprint(usr)

						usr.visible_message("\blue [usr] inserts a power cell into \the [src].", "\blue You insert the power cell into \the [src].")

		src.updateDialog()
	else
		usr << browse(null, "window=aircond")
		usr.unset_machine()
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
