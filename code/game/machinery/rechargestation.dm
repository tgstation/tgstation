/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/open = 1
	var/construct_op = 0
	var/circuitboard = "/obj/item/weapon/circuitboard/cyborgrecharger"
	var/locked = 1
	req_access = list(access_robotics)
	var/recharge_speed
	var/repairs
	var/mob/living/silicon/robot/occupier


/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()
	build_icon()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/weapon/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000


/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	if(src.occupier)
		process_occupier()
	return 1


/obj/machinery/recharge_station/allow_drop()
	return 0


/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupier)
		occupier.emp_act(severity)
	open_machine()
	..(severity)

/obj/machinery/recharge_station/ex_act(severity, specialty)
	if(occupier)
		open_machine()
	..()

/obj/machinery/recharge_station/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attackby(obj/item/P as obj, mob/user as mob)
	if(open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(exchange_parts(user, P))
		return

	default_deconstruction_crowbar(P)

/obj/machinery/recharge_station/attack_hand(user as mob)
	if(..())	return
	if(construct_op == 0)
		toggle_open()
	else
		user << "The recharger can't be closed in this state."
	add_fingerprint(user)

/obj/machinery/recharge_station/proc/toggle_open()
	if(open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	if(occupier)
		if (occupier.client)
			occupier.client.eye = occupier
			occupier.client.perspective = MOB_PERSPECTIVE
		occupier.loc = loc
		occupier = null
		use_power = 1
	open = 1
	density = 0
	build_icon()

/obj/machinery/recharge_station/close_machine()
	if(!panel_open)
		for(var/mob/living/silicon/robot/R in loc)
			R.stop_pulling()
			if(R.client)
				R.client.eye = src
				R.client.perspective = EYE_PERSPECTIVE
			R.loc = src
			occupier = R
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
			if(occupier)
				icon_state = "borgcharger1"
			else
				icon_state = "borgcharger2"
	else
		icon_state = "borgcharger0"

/obj/machinery/recharge_station/proc/process_occupier()
	if(occupier)
		restock_modules()
		if(repairs)
			occupier.heal_organ_damage(repairs, repairs - 1)
		if(occupier.cell)
			if(occupier.cell.charge >= occupier.cell.maxcharge)
				occupier.cell.charge = occupier.cell.maxcharge
			else
				occupier.cell.charge = min(occupier.cell.charge + recharge_speed, occupier.cell.maxcharge)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupier)
		if(occupier.module && occupier.module.modules)
			var/list/um = occupier.contents|occupier.module.modules // Makes single list of active (occupier.contents) and inactive (occupier.module.modules) modules
			var/coeff = recharge_speed / 200
			for (var/datum/robot_energy_storage/st in occupier.module.storages)
				st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)
			for(var/obj/O in um)
				//General
				if(istype(O,/obj/item/device/flash))
					if(O:broken)
						O:broken = 0
						O:times_used = 0
						O:icon_state = "flash"
				// Engineering
				// Security
				if(istype(O,/obj/item/weapon/gun/energy/taser/cyborg))
					if(O:power_supply.charge < O:power_supply.maxcharge)
						var/obj/item/weapon/gun/energy/G = O
						var/obj/item/ammo_casing/energy/S = G.ammo_type[G.select]
						O:power_supply.give(S.e_cost * coeff)
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
						O.reagents.add_reagent("enzyme", 2 * coeff)
				//Medical
				if(istype(O,/obj/item/weapon/reagent_containers/glass/bottle/robot))
					var/obj/item/weapon/reagent_containers/glass/bottle/robot/B = O
					if(B.reagent && (B.reagents.get_reagent_amount(B.reagent) < B.volume))
						B.reagents.add_reagent(B.reagent, 2 * coeff)
				//Janitor
				if(istype(O, /obj/item/device/lightreplacer))
					var/obj/item/device/lightreplacer/LR = O
					var/i = 1
					for(1, i <= coeff, i++)
						LR.Charge(occupier)

			if(occupier)
				if(occupier.module)
					occupier.module.respawn_consumable(occupier)

			//Emagged items for janitor and medical borg
			if(occupier.module.emag)
				if(istype(occupier.module.emag, /obj/item/weapon/reagent_containers/spray))
					var/obj/item/weapon/reagent_containers/spray/S = occupier.module.emag
					if(S.name == "polyacid spray")
						S.reagents.add_reagent("pacid", 2 * coeff)
					else if(S.name == "lube spray")
						S.reagents.add_reagent("lube", 2 * coeff)
