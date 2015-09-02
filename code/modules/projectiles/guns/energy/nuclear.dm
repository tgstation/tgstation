/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: Disable and kill."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=3;magnets=2"
	modifystate = 2
	can_flashlight = 1
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/weapon/gun/energy/gun/attack_self(mob/living/user)
	select_fire(user)
	update_icon()

/obj/item/weapon/gun/energy/gun/hos
	desc = "This is a expensive, modern recreation of a antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 4

/obj/item/weapon/gun/energy/gun/dragnet
	name = "DRAGnet"
	desc = "The \"Dynamic Rapid-Apprehension of the Guilty\" net is a revolution in law enforcement technology."
	icon_state = "dragnet"
	origin_tech = "combat=3;magnets=3;materials=4; bluespace=4"
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	can_flashlight = 0
	ammo_x_offset = 1

/obj/item/weapon/gun/energy/gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = 5
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	heavy_weapon = 1
	can_flashlight = 0
	trigger_guard = 0
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	item_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/fail_state = 0
	var/charge_tick = 0
	can_flashlight = 0
	pin = null
	can_charge = 0
	ammo_x_offset = 1

/obj/item/weapon/gun/energy/gun/nuclear/New()
	..()
	SSobj.processing |= src


/obj/item/weapon/gun/energy/gun/nuclear/Destroy()
	SSobj.processing.Remove(src)
	return ..()


/obj/item/weapon/gun/energy/gun/nuclear/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	if((power_supply.charge / power_supply.maxcharge) != 1)
		if(!failcheck())	return 0
		power_supply.give(100)
		update_icon()
	return 1


/obj/item/weapon/gun/energy/gun/nuclear/proc/failcheck()
	fail_state  = 0
	if (prob(src.reliability)) return 1 //No failure
	if (prob(src.reliability))
		for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
			if (src in M.contents)
				M << "<span class='danger'>Your gun feels pleasantly warm for a moment.</span>"
			else
				M << "<span class='danger'>You feel a warm sensation.</span>"
			M.irradiate(rand(3,120))
		fail_state = 1
	else
		for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
			if (src in M.contents)
				M << "<span class='danger'>Your gun's reactor overloads!</span>"
			M << "<span class='danger'>You feel a wave of heat wash over you.</span>"
			M.irradiate(300)
		fail_state = 2 //break the gun so it stops recharging
		SSobj.processing.Remove(src)
		update_icon()
	return 0

/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	reliability -= round(15/severity)

/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	..()
	overlays += "[icon_state]_fail_[fail_state]"
