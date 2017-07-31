/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	desc = "A charging dock for energy based weaponry."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250
	var/obj/item/charging = null
	var/static/list/allowed_devices = typecacheof(list(/obj/item/weapon/gun/energy, /obj/item/weapon/melee/baton, /obj/item/ammo_box/magazine/recharge, /obj/item/device/modular_computer))
	var/recharge_coeff = 1

/obj/machinery/recharger/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/recharger/B = new()
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/recharger
	name = "Weapon Recharger (Machine Board)"
	build_path = /obj/machinery/recharger
	origin_tech = "powerstorage=4;engineering=3;materials=4"
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user, params)
	if(istype(G, /obj/item/weapon/wrench))
		if(charging)
			to_chat(user, "<span class='notice'>Remove the charging item first!</span>")
			return
		anchored = !anchored
		power_change()
		to_chat(user, "<span class='notice'>You [anchored ? "attached" : "detached"] [src].</span>")
		playsound(loc, G.usesound, 75, 1)
		return

	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging || panel_open)
				return 1

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || a.power_equip == 0)
				to_chat(user, "<span class='notice'>[src] blinks red as you try to insert [G].</span>")
				return 1

			if (istype(G, /obj/item/weapon/gun/energy))
				var/obj/item/weapon/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, "<span class='notice'>Your gun has no external power connector.</span>")
					return 1

			if(!user.drop_item())
				return 1
			G.loc = src
			charging = G
			use_power = ACTIVE_POWER_USE
			update_icon(scan = TRUE)
		else
			to_chat(user, "<span class='notice'>[src] isn't connected to anything!</span>")
		return 1

	if(anchored && !charging)
		if(default_deconstruction_screwdriver(user, "rechargeropen", "recharger0", G))
			return

		if(panel_open && istype(G, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(G)
			return

		if(exchange_parts(user, G))
			return
	return ..()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.loc = loc
		user.put_in_hands(charging)
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.loc = loc
		charging = null
		use_power = IDLE_POWER_USE
		update_icon()

/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	var/using_power = 0
	if(charging)
		var/obj/item/weapon/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff)
				use_power(250 * recharge_coeff)
				using_power = 1
			update_icon(using_power)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			E.recharge_newshot()
			return
		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				use_power(200 * recharge_coeff)
				using_power = 1
			update_icon(using_power)
			return

/obj/machinery/recharger/power_change()
	..()
	update_icon()

/obj/machinery/recharger/emp_act(severity)
	if(!(stat & (NOPOWER|BROKEN)) && anchored)
		if(istype(charging,  /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.cell)
				E.cell.emp_act(severity)

		else if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.cell)
				B.cell.charge = 0
	..()


/obj/machinery/recharger/update_icon(using_power = 0, scan)	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = "rechargeroff"
		return
	if(scan)
		icon_state = "rechargeroff"
		return
	if(panel_open)
		icon_state = "rechargeropen"
		return
	if(charging)
		if(using_power)
			icon_state = "recharger1"
		else
			icon_state = "recharger2"
		return
	icon_state = "recharger0"
