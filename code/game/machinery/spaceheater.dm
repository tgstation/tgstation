/obj/machinery/space_heater
	anchored = 0
	density = 1
	icon = 'atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	var/obj/item/weapon/cell/cell
	var/on = 0
	var/open = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000

	flags = FPRINT


	New()
		..()
		cell = new(src)
		cell.charge = 1000
		cell.maxcharge = 1000
		update_icon()
		return

	update_icon()
		overlays = null
		icon_state = "sheater[on]"
		if(open)
			overlays  += "sheater-open"
		return

	examine()
		set src in oview(12)
		if (!( usr ))
			return
		usr << "This is \icon[src] \an [src.name]."
		usr << src.desc

		usr << "The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
		if(open)
			usr << "The power cell is [cell ? "installed" : "missing"]."
		else
			usr << "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"
		return


	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/weapon/cell))
			if(open)
				if(cell)
					user << "There is already a power cell inside."
					return
				else
					// insert cell
					var/obj/item/weapon/cell/C = usr.equipped()
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
				user << browse(null, "window=spaceheater")
				user.machine = null
		else
			..()
		return

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if(open)

			var/dat
			dat = "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"

			dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"

			dat += "Set Temperature: "

			dat += "<A href='?src=\ref[src];op=temp;val=-5'>-</A>"

			dat += " [set_temperature]&deg;C "
			dat += "<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"

			user.machine = src
			user << browse("<HEAD><TITLE>Space Heater Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=spaceheater")
			onclose(user, "spaceheater")




		else
			on = !on
			user.visible_message("\blue [user] switches [on ? "on" : "off"] the [src].","\blue You switch [on ? "on" : "off"] the [src].")
			update_icon()
		return


	Topic(href, href_list)
		if (usr.stat)
			return
		if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
			usr.machine = src

			switch(href_list["op"])

				if("temp")
					var/value = text2num(href_list["val"])

					// limit to 20-90 degC
					set_temperature = dd_range(20, 90, set_temperature + value)

				if("cellremove")
					if(open && cell && !usr.equipped())
						cell.loc = usr
						cell.layer = 20
						if(usr.hand)
							usr.l_hand = cell
						else
							usr.r_hand = cell

						cell.add_fingerprint(usr)
						cell.updateicon()
						cell = null

						usr.visible_message("\blue [usr] removes the power cell from \the [src].", "\blue You remove the power cell from \the [src].")


				if("cellinstall")
					if(open && !cell)
						var/obj/item/weapon/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.loc = src
							C.add_fingerprint(usr)

							usr.visible_message("\blue [usr] inserts a power cell into \the [src].", "\blue You insert the power cell into \the [src].")

			updateDialog()
		else
			usr << browse(null, "window=spaceheater")
			usr.machine = null
		return



	process()
		if(on)
			if(cell && cell.charge > 0)

				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (set_temperature+T0C))

						var/transfer_moles = 0.25 * env.total_moles()

						var/datum/gas_mixture/removed = env.remove(transfer_moles)

						//world << "got [transfer_moles] moles at [removed.temperature]"

						if(removed)

							var/heat_capacity = removed.heat_capacity()
							//world << "heating ([heat_capacity])"
							if(heat_capacity == 0 || heat_capacity == null) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
								heat_capacity = 1
							removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
							cell.use(heating_power/20000)

							//world << "now at [removed.temperature]"

						env.merge(removed)

						//world << "turf now at [env.temperature]"


			else
				on = 0
				update_icon()


		return