/obj/machinery/recharge_station
	name = "Cyborg Recharging Station"
	icon = 'cloning.dmi'
	icon_state = "pod_0"
	density = 1
	anchored = 1.0

	var/mob/occupant = null



	New()
		..()
		build_icon()

	process()
		..()
		if(!(NOPOWER|BROKEN))
			return

		if(src.occupant)
			process_occupant()
		return 1


	allow_drop()
		return 0


	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	proc
		build_icon()
			if(NOPOWER|BROKEN)
				if(src.occupant)
					icon_state = "pod_1"
				else
					icon_state = "pod_0"
			else
				icon_state = "pod_0"

		process_occupant()
			if(src.occupant)
				if (istype(occupant, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = occupant
					restock_modules()
					if(!R.cell)
						return
					else if(R.cell.charge >= R.cell.maxcharge)
						R.cell.charge = R.cell.maxcharge
						return
					else
						R.cell.charge += 50
						use_power(50)
						return


				else if (istype(occupant, /mob/living/silicon/hivebot))
					var/mob/living/silicon/hivebot/H = occupant

					if(H.energy  >= H.energy_max)
						H.energy  = H.energy_max
						return
					else
						H.energy += 50
						use_power(50)
						return

		go_out()
			if(!( src.occupant ))
				return
			//for(var/obj/O in src)
			//	O.loc = src.loc
			if (src.occupant.client)
				src.occupant.client.eye = src.occupant.client.mob
				src.occupant.client.perspective = MOB_PERSPECTIVE
			src.occupant.loc = src.loc
			src.occupant = null
			build_icon()
			return

		restock_modules()
			if(src.occupant)
				if (istype(occupant, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = occupant
					for(var/obj/O in R)
						// Engineering
						if(istype(O,/obj/item/weapon/rcd))
							if(O:matter < 30)
								O:matter += 1
						if(istype(O,/obj/item/stack/sheet/metal) || istype(O,/obj/item/stack/sheet/rglass) || istype(O,/obj/item/weapon/cable_coil))
							if(O:amount < 50)
								O:amount += 1
						// Security
						if(istype(O,/obj/item/device/flash))
							if(O:shots < 5)
								O:shots += 1
						if(istype(O,/obj/item/weapon/gun/energy/taser_gun))
							if(O:charges < 4)
								O:charges += 1
						if(istype(O,/obj/item/weapon/baton))
							if(O:charges < 10)
								O:charges += 1



	verb
		move_eject()
			set src in oview(1)
			if (usr.stat != 0)
				return
			src.go_out()
			add_fingerprint(usr)
			return

		move_inside()
			set src in oview(1)
			if (usr.stat != 0 || stat & (NOPOWER|BROKEN))
				return
			if (!(istype(usr, /mob/living/silicon/)))
				usr << "\blue <B>Only non-organics may enter the recharger!</B>"
				return
			if (src.occupant)
				usr << "\blue <B>The cell is already occupied!</B>"
				return
			usr.pulling = null
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			src.occupant = usr
			/*for(var/obj/O in src)
				O.loc = src.loc*/
			src.add_fingerprint(usr)
			build_icon()
			return





