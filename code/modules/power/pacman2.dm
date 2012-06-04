//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05


//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen/pacman2
	name = "Pacman II"
	desc = "P.A.C.M.A.N. type II portable generator. Uses liquid plasma as a fuel source."
	power_gen = 4500
	var/obj/item/weapon/tank/plasma/P = null
	var/board_path = "/obj/item/weapon/circuitboard/pacman2"
	var/emagged = 0
	var/heat = 0
/*
	process()
		if(P)
			if(P.air_contents.toxins <= 0)
				P.air_contents.toxins = 0
				eject()
			else
				P.air_contents.toxins -= 0.001
		return
*/

	HasFuel()
		if(P.air_contents.toxins >= 0.1)
			return 1
		return 0

	UseFuel()
		P.air_contents.toxins -= 0.01
		return

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new board_path(src)
		RefreshParts()

	RefreshParts()
		var/temp_rating = 0
		var/temp_reliability = 0
		for(var/obj/item/weapon/stock_parts/SP in component_parts)
			if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
				//max_coins = SP.rating * SP.rating * 1000
			else if(istype(SP, /obj/item/weapon/stock_parts/micro_laser) || istype(SP, /obj/item/weapon/stock_parts/capacitor))
				temp_rating += SP.rating
		for(var/obj/item/weapon/CP in component_parts)
			temp_reliability += CP.reliability
		reliability = min(round(temp_reliability / 4), 100)
		power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

	examine()
		..()
		usr << "\blue The generator has [P.air_contents.toxins] units of fuel left, producing [power_gen] per cycle."
		if(crit_fail) usr << "\red The generator seems to have broken down."

	handleInactive()
		heat -= 2
		if (heat < 0)
			heat = 0
		else
			for(var/mob/M in viewers(1, src))
				if (M.client && M.machine == src)
					src.updateUsrDialog()

	proc
		overheat()
			explosion(get_turf(src), 2, 5, 2, -1)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O, /obj/item/weapon/tank/plasma))
			if(P)
				user << "\red The generator already has a plasma tank loaded!"
				return
			P = O
			user.drop_item()
			O.loc = src
			user << "\blue You add the plasma tank to the generator."
		else if (istype(O, /obj/item/weapon/card/emag))
			var/obj/item/weapon/card/emag/E = O
			if(E.uses)
				E.uses--
			else
				return
			emagged = 1
			emp_act(1)
		else if(!active)
			if(istype(O, /obj/item/weapon/wrench))
				anchored = !anchored
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				if(anchored)
					user << "\blue You secure the generator to the floor."
				else
					user << "\blue You unsecure the generator from the floor."
				makepowernets()
			else if(istype(O, /obj/item/weapon/screwdriver))
				open = !open
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				if(open)
					user << "\blue You open the access panel."
				else
					user << "\blue You close the access panel."
			else if(istype(O, /obj/item/weapon/crowbar) && !open)
				var/obj/machinery/constructable_frame/machine_frame/new_frame = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				for(var/obj/item/I in component_parts)
					if(I.reliability < 100)
						I.crit_fail = 1
					I.loc = src.loc
				new_frame.state = 2
				new_frame.icon_state = "box_1"
				del(src)

	attack_hand(mob/user as mob)
		..()
		if (!anchored)
			return

		interact(user)

	attack_ai(mob/user as mob)
		interact(user)

	attack_paw(mob/user as mob)
		interact(user)

	proc
		interact(mob/user)
			if (get_dist(src, user) > 1 )
				if (!istype(user, /mob/living/silicon/ai))
					user.machine = null
					user << browse(null, "window=port_gen")
					return

			user.machine = src

			var/dat = text("<b>[name]</b><br>")
			if (active)
				dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
			else
				dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
			if(P)
				dat += text("Currently loaded plasma tank: [P.air_contents.toxins]<br>")
			else
				dat += text("No plasma tank currently loaded.<br>")
			dat += text("Power output: <A href='?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='?src=\ref[src];action=higher_power'>+</A><br>")
			dat += text("Heat: [heat]<br>")
			dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
			user << browse("[dat]", "window=port_gen")

	Topic(href, href_list)
		if(..())
			return

		src.add_fingerprint(usr)
		if(href_list["action"])
			if(href_list["action"] == "enable")
				if(!active && HasFuel() && !crit_fail)
					active = 1
					icon_state = "portgen1"
					src.updateUsrDialog()
			if(href_list["action"] == "disable")
				if (active)
					active = 0
					icon_state = "portgen0"
					src.updateUsrDialog()
			if(href_list["action"] == "lower_power")
				if (power_output > 1)
					power_output--
					src.updateUsrDialog()
			if (href_list["action"] == "higher_power")
				if (power_output < 4 || emagged)
					power_output++
					src.updateUsrDialog()
			if (href_list["action"] == "close")
				usr << browse(null, "window=port_gen")
				usr.machine = null
