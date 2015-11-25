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
	var/list/acceptable_upgradeables = list(/obj/item/weapon/cell) // battery for now
	var/list/upgrade_holder = list()
	var/upgrading = 0 // are we upgrading a nigga?
	var/upgrade_finished = -1 // time the upgrade should finish
	var/manipulator_coeff = 1 // better manipulator swaps parts faster
	var/transfer_rate_coeff = 1 // transfer rate bonuses
	var/capacitor_stored = 0 //power stored in capacitors, to be instantly transferred to robots when they enter the charger
	var/capacitor_max = 0 //combined max power the capacitors can hold
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EJECTNOTDEL

/obj/machinery/recharge_station/New()
	. = ..()
	build_icon()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/recharge_station,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin
	)

	RefreshParts()

/obj/machinery/recharge_station/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating-1
	manipulator_coeff = initial(manipulator_coeff)+(T)
	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating-1
	transfer_rate_coeff = initial(transfer_rate_coeff)+(T * 0.2)
	capacitor_max = initial(capacitor_max)+(T * 750)
	active_power_usage = 1000 * transfer_rate_coeff

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
	process_upgrade()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(src.occupant)
		process_occupant()
	else
		process_capacitors()
	return 1

/obj/machinery/recharge_station/proc/process_upgrade()
	if(!upgrading)
		return
	if(!occupant || !isrobot(occupant)) // Something happened so stop the upgrade.
		upgrading = 0
		upgrade_finished = -1
		return
	if(stat & (NOPOWER|BROKEN) || !anchored)
		to_chat(occupant, "<span class='warning'>Upgrade interrupted due to power failure, movement lock is released.</span>")
		upgrading = 0
		upgrade_finished = -1
		return
	if(world.timeofday >= upgrade_finished && upgrade_finished != -1)
		if(istype(upgrading, /obj/item/weapon/cell))
			if(occupant:cell)
				occupant:cell.loc = get_turf(src)
			upgrade_holder -= upgrading
			upgrading:loc = occupant
			occupant:cell = upgrading
			occupant:cell:charge = occupant:cell.maxcharge // its been in a recharger so it makes sense
			upgrading = 0
			upgrade_finished = -1
			to_chat(occupant, "<span class='notice'>Upgrade completed.</span>")
			playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/recharge_station/attackby(var/obj/item/W, var/mob/living/user)
	if(is_type_in_list(W, acceptable_upgradeables))
		if(!(locate(W.type) in upgrade_holder))
			user.drop_item(W, src)
			upgrade_holder.Add(W)
			to_chat(user, "<span class='notice'>You add \the [W] to \the [src].</span>")
			return
		else
			to_chat(user, "<span class='notice'>\The [src] already contains something resembling a [W.name].</span>")
			return
	else
		..()
		return
	return

/obj/machinery/recharge_station/attack_ghost(var/mob/user) //why would they
	return 0

/obj/machinery/recharge_station/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/recharge_station/attack_hand(var/mob/user)
	if(user == occupant)
		if(upgrading)
			to_chat(user, "<span class='notice'>You interrupt the upgrade process.</span>")
			upgrading = 0
			upgrade_finished = -1
			return 0
		else if(upgrade_holder.len)
			upgrading = input(user, "Choose an item to swap out.","Upgradeables") as null|anything in upgrade_holder
			if(!upgrading)
				upgrading = 0
				return
			if(alert(user, "You have chosen [upgrading], is this correct?", , "Yes", "No") == "Yes")
				upgrade_finished = world.timeofday + (600/manipulator_coeff)
				to_chat(user, "The upgrade should complete in approximately [60/manipulator_coeff] seconds, you will be unable to exit \the [src] during this unless you cancel the process.")
				spawn() do_after(user,src,600/manipulator_coeff,needhand = FALSE)
				return
			else
				upgrading = 0
				to_chat(user, "You decide not to apply the upgrade")
				return
	else if(Adjacent(user))
		if(upgrade_holder.len)
			var/obj/removed = input(user, "Choose an item to remove.",upgrade_holder[1]) as null|anything in upgrade_holder
			if(!removed)
				return
			user.put_in_hands(removed)
			if(removed.loc == src)
				removed.loc = get_turf(src)
			upgrade_holder -= removed

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
			if((R.stat) || (!R.client))//no more borgs suiciding in recharge stations to ruin them.
				go_out()
				return
			restock_modules()
			if(!R.cell)
				return
			else if(R.cell.charge >= R.cell.maxcharge)
				R.cell.charge = R.cell.maxcharge
				return
			else
				if (capacitor_stored)
					var/juicetofill = R.cell.maxcharge-R.cell.charge
					if(capacitor_stored > juicetofill)
						capacitor_stored -= juicetofill
						R.cell.charge = R.cell.maxcharge
					else
						R.cell.charge = R.cell.charge + capacitor_stored
						capacitor_stored = 0
				R.cell.charge = min(R.cell.charge + 200 * transfer_rate_coeff + (isMoMMI(occupant) ? 100 * transfer_rate_coeff : 0), R.cell.maxcharge)
				return

/obj/machinery/recharge_station/proc/process_capacitors()
	if (capacitor_stored >= capacitor_max)
		if (idle_power_usage != initial(idle_power_usage)) //probably better to not re-assign the variable each process()?
			idle_power_usage = initial(idle_power_usage)
		return 0
	idle_power_usage = initial(idle_power_usage) + (100 * transfer_rate_coeff)
	capacitor_stored = min(capacitor_stored + (20 * transfer_rate_coeff), capacitor_max)
	return 1

/obj/machinery/recharge_station/proc/go_out()
	if(!( src.occupant ))
		return
	if(upgrading)
		to_chat(occupant, "<span class='notice'>The upgrade hasn't completed yet, interface with \the [src] again to halt the process.</span>")
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
	// Removes dropped items/magically appearing mobs from the charger too
	for (var/atom/movable/x in src.contents)
		if(!(x in upgrade_holder | component_parts))
			x.forceMove(src.loc)
	return

/obj/machinery/recharge_station/proc/restock_modules()
	if(src.occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			if(R.module && R.module.modules)
				var/list/um = R.contents|R.module.modules
				// ^ makes single list of active (R.contents) and inactive modules (R.module.modules)
				for(var/obj/O in um)
					// Stacks
					if(istype(O,/obj/item/stack))
						var/obj/item/stack/S=O
						if(!istype(S,/obj/item/stack/cable_coil) && !istype(S,/obj/item/stack/medical))
							continue //Only recharge cable coils and medical stacks

						if(S.amount < S.max_amount)
							S.amount += 2
						if(S.amount > S.max_amount)
							S.amount = S.max_amount
					// Security
					if(istype(O,/obj/item/device/flash))
						var/obj/item/device/flash/F=O
						if(F.broken)
							F.broken = 0
							F.times_used = 0
							F.icon_state = "flash"
					if(istype(O,/obj/item/weapon/gun/energy/taser/cyborg))
						var/obj/item/weapon/gun/energy/taser/cyborg/C=O
						if(C.power_supply.charge < C.power_supply.maxcharge)
							C.power_supply.give(C.charge_cost)
							C.update_icon()
						else
							C.charge_tick = 0
					if(istype(O,/obj/item/weapon/melee/baton))
						var/obj/item/weapon/melee/baton/B = O
						if(B.bcell)
							B.bcell.charge = B.bcell.maxcharge
					//Combat
					if(istype(O,/obj/item/weapon/gun/energy/laser/cyborg))
						var/obj/item/weapon/gun/energy/laser/cyborg/C=O
						if(C.power_supply.charge < C.power_supply.maxcharge)
							C.power_supply.give(C.charge_cost)
							C.update_icon()
						else
							C.charge_tick = 0
					if(istype(O,/obj/item/weapon/gun/energy/lasercannon/cyborg))
						var/obj/item/weapon/gun/energy/lasercannon/cyborg/C=O
						if(C.power_supply.charge < C.power_supply.maxcharge)
							C.power_supply.give(C.charge_cost)
							C.update_icon()
					//Mining
					if(istype(O,/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg))
						var/obj/item/weapon/gun/energy/kinetic_accelerator/cyborg/C=O
						if(C.power_supply.charge < C.power_supply.maxcharge)
							C.power_supply.give(C.charge_cost)
							C.update_icon()
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

	mob_enter(usr)
	return

/obj/machinery/recharge_station/proc/mob_enter(mob/living/silicon/robot/R)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return
	if (R.stat == 2)
		//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
		return
	if (!(istype(R, /mob/living/silicon/)))
		to_chat(R, "<span class='notice'><B>Only non-organics may enter the recharger!</B></span>")
		return
	if (src.occupant)
		to_chat(R, "<span class='notice'><B>The cell is already occupied!</B></span>")
		return
	R.stop_pulling()
	if(R && R.client)
		R.client.perspective = EYE_PERSPECTIVE
		R.client.eye = src
	R.loc = src
	src.occupant = R
	src.add_fingerprint(R)
	build_icon()
	src.use_power = 2
	for(var/obj/O in upgrade_holder)
		if(istype(O, /obj/item/weapon/cell))
			if(!R.cell)
				to_chat(usr, "<big><span class='notice'>Power Cell replacement available.</span></big>")
			else
				if(O:maxcharge > R.cell.maxcharge)
					to_chat(usr, "<span class='notice'>Power Cell upgrade available.</span></big>")

/obj/machinery/recharge_station/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(occupant)
		to_chat(user, "<span class='notice'>You can't do that while this charger is occupied.</span>")
		return -1
	return ..()

/obj/machinery/recharge_station/crowbarDestroy(mob/user)
	if(occupant)
		to_chat(user, "<span class='notice'>You can't do that while this charger is occupied.</span>")
		return -1
	return ..()



/obj/machinery/recharge_station/Bumped(atom/AM as mob|obj)
	if(!issilicon(AM) || isAI(AM))
		return
	var/mob/living/silicon/robot/R = AM
	mob_enter(R)
	return