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

	var/self_powered = 0

	var/obj/item/weapon/charging = null

	var/appearance_backup = null

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/recharger/New()
	..()
	if(self_powered)
		use_power = 0
		idle_power_usage = 0
		active_power_usage = 0

/obj/machinery/recharger/Destroy()
	if(charging)
		charging.appearance = appearance_backup
		charging.update_icon()
		charging.loc = loc
		charging = null
	appearance_backup=null
	..()

/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user)
	if(istype(user,/mob/living/silicon))
		return
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton) || istype(G, /obj/item/energy_magazine) || istype(G, /obj/item/ammo_storage/magazine/lawgiver))
		if(charging)
			to_chat(user, "<span class='warning'>There's \a [charging] already charging inside!</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>You must anchor \the [src] before you can make use of it!</span>")
			return

		//Checks to make sure the recharger is powered and functional
		if(stat & (NOPOWER | BROKEN))
			to_chat(user, "<span class='notice'>[src] isn't connected to a power source.</span>")
			return

		if (istype(G, /obj/item/weapon/gun/energy/gun/nuclear) || istype(G, /obj/item/weapon/gun/energy/crossbow))
			to_chat(user, "<span class='notice'>Your gun's recharge port was removed to make room for a miniaturized reactor.</span>")
			return
		if (istype(G, /obj/item/weapon/gun/energy/staff))
			to_chat(user, "<span class='notice'>The recharger rejects the magical apparatus.</span>")
			return
		appearance_backup = G.appearance
		var/matrix/M = matrix()
		M.Scale(0.625)
		M.Translate(0,6)
		G.transform = M
		user.drop_item(G, src)
		charging = G
		if(!self_powered)
			use_power = 2
		update_icon()
		return
	..()

/obj/machinery/recharger/wrenchAnchor(mob/user)
	if(charging)
		to_chat(user, "<span class='notice'>Remove the charging item first!</span>")
		return
	if(..() == 1)
		pixel_x = 0
		pixel_y = 0
		update_icon()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user) || ..())
		return 1

	add_fingerprint(user)

	if(charging && Adjacent(user))
		charging.appearance = appearance_backup
		charging.update_icon()
		charging.loc = loc
		user.put_in_hands(charging)
		charging = null
		if(!self_powered)
			use_power = 1
		appearance_backup=null
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/recharger/process()
	if(!anchored)
		icon_state = "recharger4"
		return

	if(!self_powered && (stat & (NOPOWER|BROKEN)))
		if(charging)//Spit out anything being charged if it loses power or breaks
			charging.appearance = appearance_backup
			charging.update_icon()
			charging.loc = loc
			visible_message("<span class='notice'>[src] powers down and ejects \the [charging].</span>")
			charging = null
			use_power = 1
			appearance_backup=null
			update_icon()
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if((E.power_supply.charge + 100) < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "recharger1"
				if(!self_powered)
					use_power(250)
				update_icon()
			else
				E.power_supply.charge = E.power_supply.maxcharge
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/energy_magazine))//pulse bullet casings
			var/obj/item/energy_magazine/M = charging
			if((M.bullets + 3) < M.max_bullets)
				M.bullets = min(M.max_bullets,M.bullets+3)
				icon_state = "recharger1"
				if(!self_powered)
					use_power(250)
				update_icon()
			else
				M.bullets = M.max_bullets
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/ammo_storage/magazine/lawgiver))
			var/obj/item/ammo_storage/magazine/lawgiver/L = charging
			if(!L.isFull())
				if(L.stuncharge != 100)
					L.stuncharge += 20
				else if(L.lasercharge != 100)
					L.lasercharge += 20
				else if(L.rapid_ammo_count != 5)
					L.rapid_ammo_count++
				else if(L.flare_ammo_count != 5)
					L.flare_ammo_count++
				else if(L.hi_ex_ammo_count != 5)
					L.hi_ex_ammo_count++
				icon_state = "recharger1"
				if(!self_powered)
					use_power(200)
				update_icon()
			else
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "recharger1"
					if(!self_powered)
						use_power(200)
				else
					icon_state = "recharger2"
			else
				icon_state = "recharger0"

/obj/machinery/recharger/emp_act(severity)
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

/obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		overlays.len = 0
		charging.update_icon()
		overlays += charging.appearance
		icon_state = "recharger1"
	else
		overlays.len = 0
		icon_state = "recharger0"

/obj/machinery/recharger/self_powered	//ideal for the Thunderdome
	self_powered = 1

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"

/obj/machinery/recharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "wrecharger1"
				if(!self_powered)
					use_power(250)
			else
				icon_state = "wrecharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "wrecharger1"
					if(!self_powered)
						use_power(200)
				else
					icon_state = "wrecharger2"
			else
				icon_state = "wrecharger3"