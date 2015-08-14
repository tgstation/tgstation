/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: Disable and kill."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=3;magnets=2"
	modifystate = 2
	can_flashlight = 1

/obj/item/weapon/gun/energy/gun/attack_self(mob/living/user)
	select_fire(user)
	update_icon()

/obj/item/weapon/gun/energy/gun/hos
	desc = "This is a expensive, modern recreation of a antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	item_state = null
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler)

/obj/item/weapon/gun/energy/gun/dragnet
	name = "DRAGnet"
	desc = "The \"Dynamic Rapid-Apprehension of the Guilty\" net is a revolution in law enforcement technology."
	icon_state = "dragnet"
	item_state = null
	origin_tech = "combat=3;magnets=3;materials=4; bluespace=4"
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	can_flashlight = 0

/obj/item/weapon/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	var/charge_tick = 0
	modifystate = 0
	can_flashlight = 0
	pin = null
	can_charge = 0

/obj/item/weapon/gun/energy/gun/nuclear/New()
	..()
	SSobj.processing |= src


/obj/item/weapon/gun/energy/gun/nuclear/Destroy()
	SSobj.processing.Remove(src)
	..()


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
	lightfail = 0
	if (prob(src.reliability)) return 1 //No failure
	if (prob(src.reliability))
		for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
			if (src in M.contents)
				M << "<span class='danger'>Your gun feels pleasantly warm for a moment.</span>"
			else
				M << "<span class='danger'>You feel a warm sensation.</span>"
			M.irradiate(rand(3,120))
		lightfail = 1
	else
		for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
			if (src in M.contents)
				M << "<span class='danger'>Your gun's reactor overloads!</span>"
			M << "<span class='danger'>You feel a wave of heat wash over you.</span>"
			M.irradiate(300)
		crit_fail = 1 //break the gun so it stops recharging
		SSobj.processing.Remove(src)
		update_icon()
	return 0


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_charge()
	if (crit_fail)
		overlays += "nucgun-whee"
		return
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = Ceiling(ratio*4) * 25
	overlays += "nucgun-[ratio]"


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_reactor()
	if(crit_fail)
		overlays += "nucgun-crit"
		return
	if(lightfail)
		overlays += "nucgun-medium"
	else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
		overlays += "nucgun-light"
	else
		overlays += "nucgun-clean"


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_mode()
	if (select == 1)
		overlays += "nucgun-stun"
	else if (select == 2)
		overlays += "nucgun-kill"


/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	reliability -= round(15/severity)


/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	overlays.Cut()
	update_charge()
	update_reactor()
	update_mode()

/obj/item/weapon/gun/energy/gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	slot_flags = null
	w_class = 5
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	heavy_weapon = 1
	can_flashlight = 0
	trigger_guard = 0

/obj/item/weapon/gun/energy/gun/turret/update_icon()
	icon_state = initial(icon_state)