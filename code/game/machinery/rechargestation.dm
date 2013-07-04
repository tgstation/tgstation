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

/obj/machinery/recharge_station/attack_hand(mob/user)
	if(..())	return
	toggle_open()
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
				if(istype(O,/obj/item/stack/sheet/metal) || istype(O,/obj/item/stack/sheet/rglass) || istype(O,/obj/item/stack/rods) || istype(O,/obj/item/weapon/cable_coil))
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
					if(S.name == "Polyacid spray")
						S.reagents.add_reagent("pacid", 2)
					else if(S.name == "Lube spray")
						S.reagents.add_reagent("lube", 2)