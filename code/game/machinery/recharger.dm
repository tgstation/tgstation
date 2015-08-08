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

	var/image/occupant_overlay=null

	machine_flags = WRENCHMOVE | FIXED2WORK


/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton) || istype(G, /obj/item/osipr_magazine))
		if(charging)
			user << "<span class='warning'>There's \a [charging] already charging inside!</span>"
			return
		if(!anchored)
			user << "<span class='warning'>You must anchor \the [src] before you can make use of it!</span>"
			return

		//Checks to make sure the recharger is powered and functional
		if(stat & (NOPOWER | BROKEN))
			user << "<span class='notice'>[src] isn't connected to a power source.</span>"
			return

		if (istype(G, /obj/item/weapon/gun/energy/gun/nuclear) || istype(G, /obj/item/weapon/gun/energy/crossbow))
			user << "<span class='notice'>Your gun's recharge port was removed to make room for a miniaturized reactor.</span>"
			return
		if (istype(G, /obj/item/weapon/gun/energy/staff))
			return
		user.drop_item(G, src)
		charging = G
		use_power = 2
		update_icon()
		return
	..()

/obj/machinery/recharger/wrenchAnchor(mob/user)
	if(charging)
		user << "<span class='notice'>Remove the charging item first!</span>"
		return
	if(..() == 1)
		pixel_x = 0
		pixel_y = 0
		update_icon()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user) || ..())
		return 1

	if(charging && Adjacent(user))
		charging.update_icon()
		charging.loc = loc
		user.put_in_hands(charging)
		charging = null
		use_power = 1
		occupant_overlay=null
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

obj/machinery/recharger/process()
	if(!anchored)
		icon_state = "recharger4"
		return

	if(stat & (NOPOWER|BROKEN))
		icon_state = "recharger3"
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "recharger1"
				use_power(250)
			else
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/osipr_magazine))//pulse bullet casings
			var/obj/item/osipr_magazine/M = charging
			if(M.bullets < initial(M.bullets))
				M.bullets = min(initial(M.bullets),M.bullets+3)
				icon_state = "recharger1"
				use_power(250)
			else
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "recharger1"
					use_power(200)
				else
					icon_state = "recharger2"
			else
				icon_state = "recharger0"

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
		if(icon_state != "recharger2")
			overlays = 0
		icon_state = "recharger1"
	else
		overlays = 0
		icon_state = "recharger0"

	if(charging)
		charging.update_icon()
		var/icon/occupant_icon=getFlatIcon(charging)
		occupant_icon.Scale(20,20)
		occupant_overlay = image(occupant_icon)
		occupant_overlay.pixel_x=6
		occupant_overlay.pixel_y=12
		overlays += occupant_overlay

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