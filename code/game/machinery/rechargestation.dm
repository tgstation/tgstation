/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/living/silicon/robot/occupant = null
	var/open = 1
	var/construct_op = 0
	var/circuitboard = "/obj/item/weapon/circuitboard/cyborgrecharger"
	var/locked = 1
	req_access = list(access_robotics)


/obj/machinery/recharge_station/New()
	..()
	build_icon()

/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	if(src.occupant)
		process_occupant()
	return 1


/obj/machinery/recharge_station/allow_drop()
	return 0


/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	open()

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
	open()
	..(severity)

/obj/machinery/recharge_station/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attackby(obj/item/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/card/id/))
		if (construct_op == 0)
			if (src.allowed(user))
				if	(emagged == 0)
					if (locked == 1)
						user << "You turn off the ID lock."
						locked = 0
						return
					else if (locked == 0)
						user << "You turn on the ID lock."
						locked = 1
						return
				else
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
					user << "\red The ID lock is broken!"
					return
			return
		else
			user << "The ID lock can't be accessed in this state."
	else if (istype(P, /obj/item/weapon/card/emag))
		if (construct_op == 0)
			if (emagged == 0)
				emagged = 1
				locked = 0
				src.req_access = null
				user << "\red You break the ID lock on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				return
		else
			user << "The ID lock can't be accessed in this state."

	if(locked == 0)
		if(open == 1)
			switch(construct_op)
				if(0)
					if(istype(P, /obj/item/weapon/screwdriver))
						user << "You open the circuit cover."
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						icon_state = "borgdecon1"
						construct_op ++
				if(1)
					if(istype(P, /obj/item/weapon/screwdriver))
						user << "You close the circuit cover."
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						icon_state = "borgcharger0"
						construct_op --
					if(istype(P, /obj/item/weapon/wrench))
						user << "You dislodge the internal plating."
						playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
						icon_state = "borgdecon2"
						construct_op ++
				if(2)
					if(istype(P, /obj/item/weapon/wrench))
						user << "You secure the internal plating."
						playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
						icon_state = "borgdecon1"
						construct_op --
					if(istype(P, /obj/item/weapon/wirecutters))
						playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
						user << "You remove the cables."
						icon_state = "borgdecon3"
						construct_op ++
						var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( user.loc )
						A.amount = 5
						stat |= BROKEN // the machine's been borked!
				if(3)
					if(istype(P, /obj/item/weapon/cable_coil))
						var/obj/item/weapon/cable_coil/A = P
						if(A.amount >= 5)
							user << "You insert the cables."
							A.amount -= 5
							if(A.amount <= 0)
								user.drop_item()
								del(A)
							icon_state = "borgdecon2"
							construct_op --
							stat &= ~BROKEN // the machine's not borked anymore!
						else
							user << "You need more cable"
					if(istype(P, /obj/item/weapon/crowbar))
						user << "You begin prying out the circuit board and components..."
						playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
						if(do_after(user,60))
							user << "You finish prying out the components."

							// Drop all the component stuff
							if(contents.len > 0)
								for(var/obj/x in src)
									x.loc = user.loc
							else

								// If the machine wasn't made during runtime, probably doesn't have components:
								// manually find the components and drop them!
								var/newpath = text2path(circuitboard)
								var/obj/item/weapon/circuitboard/C = new newpath
								for(var/I in C.req_components)
									for(var/i = 1, i <= C.req_components[I], i++)
										newpath = text2path(I)
										var/obj/item/s = new newpath
										s.loc = user.loc
										if(istype(P, /obj/item/weapon/cable_coil))
											var/obj/item/weapon/cable_coil/A = P
											A.amount = 1

								// Drop a circuit board too
								C.loc = user.loc

							// Create a machine frame and delete the current machine
							var/obj/machinery/constructable_frame/machine_frame/F = new
							F.loc = src.loc
							del(src)
				else
					user << "This needs to be open first."
	else
		user << "This needs to be unlocked first."


/obj/machinery/recharge_station/attack_hand(user as mob)
	if(..())	return
	if(construct_op == 0)
		toggle_open()
	else
		user << "The recharger can't be closed in this state."
	add_fingerprint(user)

/obj/machinery/recharge_station/proc/toggle_open()
	if(open)
		close()
	else
		open()

/obj/machinery/recharge_station/proc/open()
	if(occupant)
		if (occupant.client)
			occupant.client.eye = occupant
			occupant.client.perspective = MOB_PERSPECTIVE
		occupant.loc = loc
		occupant = null
		use_power = 1
	open = 1
	density = 0
	build_icon()

/obj/machinery/recharge_station/proc/close()
	for(var/mob/living/silicon/robot/R in loc)
		R.stop_pulling()
		if(R.client)
			R.client.eye = src
			R.client.perspective = EYE_PERSPECTIVE
		R.loc = src
		occupant = R
		use_power = 2
		add_fingerprint(R)
		break
	open = 0
	density = 1
	build_icon()

/obj/machinery/recharge_station/proc/build_icon()
	if(NOPOWER|BROKEN)
		if(open)
			icon_state = "borgcharger0"
		else
			if(occupant)
				icon_state = "borgcharger1"
			else
				icon_state = "borgcharger2"
	else
		icon_state = "borgcharger0"

/obj/machinery/recharge_station/proc/process_occupant()
	if(occupant)
		restock_modules()
		if(occupant.cell)
			if(occupant.cell.charge >= occupant.cell.maxcharge)
				occupant.cell.charge = occupant.cell.maxcharge
			else
				occupant.cell.charge = min(occupant.cell.charge + 200, occupant.cell.maxcharge)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		if(occupant.module && occupant.module.modules)
			var/list/um = occupant.contents|occupant.module.modules
			// ^ makes sinle list of active (occupant.contents) and inactive modules (occupant.module.modules)
			for(var/obj/O in um)
				// Engineering
				if(istype(O,/obj/item/stack/sheet/metal) || istype(O,/obj/item/stack/sheet/rglass) || istype(O,/obj/item/stack/rods) || istype(O,/obj/item/weapon/cable_coil)|| istype(O,/obj/item/stack/tile/plasteel))
					if(O:amount < 50)
						O:amount += 1
				// Security
				if(istype(O,/obj/item/device/flash))
					if(O:broken)
						O:broken = 0
						O:times_used = 0
						O:icon_state = "flash"
				if(istype(O,/obj/item/weapon/gun/energy/taser/cyborg))
					if(O:power_supply.charge < O:power_supply.maxcharge)
						O:power_supply.give(O:charge_cost)
						O:update_icon()
					else
						O:charge_tick = 0
				if(istype(O,/obj/item/weapon/melee/baton))
					var/obj/item/weapon/melee/baton/B = O
					if(B.bcell)
						B.bcell.charge = B.bcell.maxcharge
				//Service
				if(istype(O,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
					if(O.reagents.get_reagent_amount("enzyme") < 50)
						O.reagents.add_reagent("enzyme", 2)
				//Medical
				if(istype(O,/obj/item/weapon/reagent_containers/glass/bottle/robot))
					var/obj/item/weapon/reagent_containers/glass/bottle/robot/B = O
					if(B.reagent && (B.reagents.get_reagent_amount(B.reagent) < B.volume))
						B.reagents.add_reagent(B.reagent, 2)
				//Janitor
				if(istype(O, /obj/item/device/lightreplacer))
					var/obj/item/device/lightreplacer/LR = O
					LR.Charge(occupant)

			if(occupant)
				if(occupant.module)
					occupant.module.respawn_consumable(occupant)

			//Emagged items for janitor and medical borg
			if(occupant.module.emag)
				if(istype(occupant.module.emag, /obj/item/weapon/reagent_containers/spray))
					var/obj/item/weapon/reagent_containers/spray/S = occupant.module.emag
					if(S.name == "polyacid spray")
						S.reagents.add_reagent("pacid", 2)
					else if(S.name == "lube spray")
						S.reagents.add_reagent("lube", 2)
