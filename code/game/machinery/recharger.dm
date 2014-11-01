/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 250

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	var/obj/item/weapon/charging = null

	machine_flags = WRENCHMOVE | FIXED2WORK


/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton))
		if(charging)
			return

		//Checks to make sure he's not in space doing it, and that the area got proper power.
		var/area/a = get_area(src)
		if(!isarea(a) || a.power_equip == 0)
			user << "<span class='notice'>[src] blinks red as you try to insert [G].</span>"
			return

		if (istype(G, /obj/item/weapon/gun/energy/gun/nuclear) || istype(G, /obj/item/weapon/gun/energy/crossbow))
			user << "<span class='notice'>Your gun's recharge port was removed to make room for a miniaturized reactor.</span>"
			return
		if (istype(G, /obj/item/weapon/gun/energy/staff))
			return
		user.drop_item()
		G.loc = src
		charging = G
		use_power = 2
		update_icon()
		return
	..()

/obj/machinery/recharger/wrenchAnchor(mob/user)
	if(charging)
		user << "<span class='notice'>Remove the charging item first!</span>"
		return
	..()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		charging.loc = loc
		user.put_in_hands(charging)
		charging = null
		use_power = 1
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "recharger1"
				use_power(250)
			else
				icon_state = "recharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "recharger1"
					use_power(200)
				else
					icon_state = "recharger2"
			else
				icon_state = "recharger3"

obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)

	else if(istype(charging, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0
	..(severity)

obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = "recharger1"
	else
		icon_state = "recharger0"

obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"

obj/machinery/recharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "wrecharger1"
				use_power(250)
			else
				icon_state = "wrecharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "wrecharger1"
					use_power(200)
				else
					icon_state = "wrecharger2"
			else
				icon_state = "wrecharger3"