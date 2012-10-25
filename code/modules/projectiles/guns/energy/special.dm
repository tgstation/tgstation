/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	fire_sound = 'sound/weapons/Laser.ogg'
	origin_tech = "combat=2;magnets=4"
	w_class = 4.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BACK
	charge_cost = 100
	projectile_type = "/obj/item/projectile/ion"

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	if(severity <= 2)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
	else
		return


/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=5;materials=4;powerstorage=3"
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/declone"

	isHandgun()
		return 0

obj/item/weapon/gun/energy/staff
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself"
	icon = 'icons/obj/gun.dmi'
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_sound = 'sound/weapons/emitter.ogg'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BACK
	w_class = 4.0
	charge_cost = 200
	projectile_type = "/obj/item/projectile/change"
	origin_tech = null
	clumsy_check = 0
	var/charge_tick = 0


	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(200)
		update_icon()
		return 1

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "floramut100"
	item_state = "obj/item/gun.dmi"
	fire_sound = 'sound/effects/stealthoff.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/floramut"
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = "floramut"
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1

	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 100
				user << "\red The [src.name] is now set to increase yield."
				projectile_type = "/obj/item/projectile/energy/florayield"
				modifystate = "florayield"
			if(1)
				mode = 0
				charge_cost = 100
				user << "\red The [src.name] is now set to induce mutations."
				projectile_type = "/obj/item/projectile/energy/floramut"
				modifystate = "floramut"
		update_icon()
		return

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	projectile_type = "/obj/item/projectile/meteor"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()

	process()
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)

	update_icon()
		return


/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = 1