/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/circuitboard = "/obj/item/weapon/circuitboard/cyborgrecharger"
	req_access = list(access_robotics)
	var/recharge_speed
	var/repairs
	state_open = 1

/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()
	update_icon()

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
	if(!is_operational())
		return

	if(occupant)
		process_occupant()
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
	if(occupant)
		occupant.emp_act(severity)
	open_machine()
	..(severity)

/obj/machinery/recharge_station/ex_act(severity, target)
	if(occupant)
		open_machine()
	..()

/obj/machinery/recharge_station/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attackby(obj/item/P as obj, mob/user as mob, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(exchange_parts(user, P))
		return

	if(default_pry_open(P))
		return

	default_deconstruction_crowbar(P)

/obj/machinery/recharge_station/attack_hand(user as mob)
	if(..(user,1,set_machine = 0))
		return

	toggle_open()
	add_fingerprint(user)

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	..()
	use_power = 1

/obj/machinery/recharge_station/close_machine()
	if(!panel_open)
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
		state_open = 0
		density = 1
		update_icon()

/obj/machinery/recharge_station/update_icon()
	if(is_operational())
		if(state_open)
			icon_state = "borgcharger0"
		else
			icon_state = (occupant ? "borgcharger1" : "borgcharger2")
	else
		icon_state = (state_open ? "borgcharger-u0" : "borgcharger-u1")

/obj/machinery/recharge_station/power_change()
	..()
	update_icon()

/obj/machinery/recharge_station/proc/process_occupant()
	if(occupant)
		var/mob/living/silicon/robot/R = occupant
		restock_modules()
		if(repairs)
			R.heal_organ_damage(repairs, repairs - 1)
		if(R.cell)
			R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		var/mob/living/silicon/robot/R = occupant
		if(R.module && R.module.modules)
			var/list/um = R.contents|R.module.modules // Makes single list of active (R.contents) and inactive (R.module.modules) modules
			var/coeff = recharge_speed / 200
			for (var/datum/robot_energy_storage/st in R.module.storages)
				st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)
			for(var/obj/O in um)
				//General
				if(istype(O,/obj/item/device/flash))
					var/obj/item/device/flash/F = O
					if(F.broken)
						F.broken = 0
						F.times_used = 0
						F.icon_state = "flash"
				// Security
				if(istype(O,/obj/item/weapon/gun/energy/gun/advtaser/cyborg))
					var/obj/item/weapon/gun/energy/gun/advtaser/cyborg/T = O
					if(T.power_supply.charge < T.power_supply.maxcharge)
						var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
						T.power_supply.give(S.e_cost * coeff)
						T.update_icon()
					else
						T.charge_tick = 0
				if(istype(O,/obj/item/weapon/melee/baton))
					var/obj/item/weapon/melee/baton/B = O
					if(B.bcell)
						B.bcell.charge = B.bcell.maxcharge
				//Service
				if(istype(O,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
					if(O.reagents.get_reagent_amount("enzyme") < 50)
						O.reagents.add_reagent("enzyme", 2 * coeff)
				//Janitor
				if(istype(O, /obj/item/device/lightreplacer))
					var/obj/item/device/lightreplacer/LR = O
					var/i = 1
					for(1, i <= coeff, i++)
						LR.Charge(R)

			if(R && R.module)
				R.module.respawn_consumable(R)

			//Emagged items for janitor and medical borg
			if(R.module.emag)
				if(istype(R.module.emag, /obj/item/weapon/reagent_containers/spray))
					var/obj/item/weapon/reagent_containers/spray/S = R.module.emag
					if(S.name == "Fluacid spray")
						S.reagents.add_reagent("facid", 2 * coeff)
					else if(S.name == "lube spray")
						S.reagents.add_reagent("lube", 2 * coeff)
