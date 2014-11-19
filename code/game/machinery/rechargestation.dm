/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/occupant = null

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

/obj/machinery/recharge_station/New()
	. = ..()
	build_icon()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/recharge_station,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin
	)

	RefreshParts()

/obj/machinery/recharge_station/Destroy()
	src.go_out()
	..()


/obj/machinery/recharge_station/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/item/weapon/circuitboard/recharge_station(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.anchored = 0
				src.build_icon()
		else
	return

/obj/machinery/recharge_station/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(src.occupant)
		process_occupant()
	return 1


/obj/machinery/recharge_station/allow_drop()
	return 0


/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	..(severity)



/obj/machinery/recharge_station/proc/build_icon()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = "borgcharger"
	else
		if(src.occupant)
			icon_state = "borgcharger1"
		else
			icon_state = "borgcharger0"

/obj/machinery/recharge_station/proc/process_occupant()
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
				R.cell.charge = min(R.cell.charge + 200  + (isMoMMI(occupant) ? 100 : 0), R.cell.maxcharge)
				return

/obj/machinery/recharge_station/proc/go_out()
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
	src.use_power = 1
	return

/obj/machinery/recharge_station/proc/restock_modules()
	if(src.occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			if(R.module && R.module.modules)
				var/list/um = R.contents|R.module.modules
				// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
				for(var/obj/O in um)
					// Engineering
					if(istype(O,/obj/item/stack/sheet/metal)\
					|| istype(O,/obj/item/stack/sheet/rglass)\
					|| istype(O,/obj/item/stack/sheet/glass)\
					|| istype(O,/obj/item/weapon/cable_coil)\
					|| istype(O,/obj/item/stack/tile/plasteel))
						if(O:amount < 50)
							O:amount += 2
						if(O:amount > 50)
							O:amount = 50
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
					//Combat
					if(istype(O,/obj/item/weapon/gun/energy/laser/cyborg))
						if(O:power_supply.charge < O:power_supply.maxcharge)
							O:power_supply.give(O:charge_cost)
							O:update_icon()
						else
							O:charge_tick = 0
					if(istype(O,/obj/item/weapon/gun/energy/lasercannon/cyborg))
						if(O:power_supply.charge < O:power_supply.maxcharge)
							O:power_supply.give(O:charge_cost)
							O:update_icon()
						else
							O:charge_tick = 0
					//Mining
					if(istype(O,/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg))
						if(O:power_supply.charge < O:power_supply.maxcharge)
							O:power_supply.give(O:charge_cost)
							O:update_icon()
						else
							O:charge_tick = 0
					//Service
					if(istype(O,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
						if(O.reagents.get_reagent_amount("enzyme") < 50)
							O.reagents.add_reagent("enzyme", 2)
					//Medical & Standard
					if(istype(O,/obj/item/weapon/reagent_containers/glass/bottle/robot))
						var/obj/item/weapon/reagent_containers/glass/bottle/robot/B = O
						if(B.reagent && (B.reagents.get_reagent_amount(B.reagent) < B.volume))
							B.reagents.add_reagent(B.reagent, 2)
					if(istype(O,/obj/item/stack/medical/bruise_pack) || istype(O,/obj/item/stack/medical/ointment) || istype(O,/obj/item/stack/medical/advanced/bruise_pack) || istype(O,/obj/item/stack/medical/advanced/ointment) || istype(O,/obj/item/stack/medical/splint))
						if(O:amount < O:max_amount)
							O:amount += 2
						if(O:amount > O:max_amount)
							O:amount = O:max_amount
					if(istype(O,/obj/item/weapon/melee/defibrillator))
						var/obj/item/weapon/melee/defibrillator/D = O
						D.charges = initial(D.charges)
					//Janitor
					if(istype(O, /obj/item/device/lightreplacer))
						var/obj/item/device/lightreplacer/LR = O
						LR.Charge(R)

				if(R)
					if(R.module)
						R.module.respawn_consumable(R)

				//Emagged items for janitor and medical borg
				if(R.module.emag)
					if(istype(R.module.emag, /obj/item/weapon/reagent_containers/spray))
						var/obj/item/weapon/reagent_containers/spray/S = R.module.emag
						if(S.name == "Polyacid spray")
							S.reagents.add_reagent("pacid", 2)
						else if(S.name == "Lube spray")
							S.reagents.add_reagent("lube", 2)



/obj/machinery/recharge_station/verb/move_eject()
	set category = "Object"
	set src in oview(1)
	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/recharge_station/verb/move_inside()
	set category = "Object"
	set src in oview(1)
	// Broken or unanchored?  Fuck off.
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return
	if (usr.stat == 2)
		//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
		return
	if (!(istype(usr, /mob/living/silicon/)))
		usr << "\blue <B>Only non-organics may enter the recharger!</B>"
		return
	if (src.occupant)
		usr << "\blue <B>The cell is already occupied!</B>"
		return
	if (!usr:cell)
		usr<<"\blue Without a powercell, you can't be recharged."
		//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
		return
	usr.stop_pulling()
	if(usr && usr.client)
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	/*for(var/obj/O in src)
		O.loc = src.loc*/
	src.add_fingerprint(usr)
	build_icon()
	src.use_power = 2
	return

/obj/machinery/recharge_station/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(occupant)
		user <<"<span class='notice'>You can't do that while this charger is occupied.</span>"
		return -1
	return ..()

/obj/machinery/recharge_station/crowbarDestroy(mob/user)
	if(occupant)
		user <<"<span class='notice'>You can't do that while this charger is occupied.</span>"
		return -1
	return ..()



