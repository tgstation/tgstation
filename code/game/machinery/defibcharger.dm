//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

obj/machinery/recharger/defibcharger/defibcharger
	name = "defib recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 150

obj/machinery/recharger/defibcharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/melee/defibrilator))
		if(charging)
			return

		// Checks to make sure he's not in space doing it, and that the area got proper power.
		var/area/a = get_area(src)
		if(!isarea(a))
			user << "\red The [name] blinks red as you try to insert the item!"
			return
		if(a.power_equip == 0)
			user << "\red The [name] blinks red as you try to insert the item!"
			return
		user.drop_item()
		G.loc = src
		charging = G
		use_power = 2
		update_icon()
	else if(istype(G, /obj/item/weapon/wrench))
		if(charging)
			user << "\red Remove the defibrilator first!"
			return
		anchored = !anchored
		user << "You [anchored ? "attached" : "detached"] the recharger."
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

obj/machinery/recharger/defibcharger/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		charging.loc = loc
		charging = null
		use_power = 1
		update_icon()

obj/machinery/recharger/defibcharger/attack_paw(mob/user as mob)
	return attack_hand(user)

obj/machinery/recharger/defibcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/melee/defibrilator))
			var/obj/item/weapon/melee/defibrilator/B = charging
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "recharger1"
				use_power(150)
			else
				icon_state = "recharger2"

obj/machinery/recharger/defibcharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging, /obj/item/weapon/melee/defibrilator))
		var/obj/item/weapon/melee/defibrilator/B = charging
		B.charges = 0
	..(severity)

obj/machinery/recharger/defibcharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = "recharger1"
	else
		icon_state = "recharger0"

obj/machinery/recharger/defibcharger/wallcharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = "wrecharger1"
	else
		icon_state = "wrecharger0"

obj/machinery/recharger/defibcharger/wallcharger
	name = "defib recharger"
	desc = "A special wall mounted recharger meant for emergency defibrilators"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"

obj/machinery/recharger/defibcharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/melee/defibrilator))
			var/obj/item/weapon/melee/defibrilator/B = charging
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "wrecharger1"
				use_power(150)
			else
				icon_state = "wrecharger2"