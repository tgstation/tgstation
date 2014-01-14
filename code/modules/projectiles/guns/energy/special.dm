/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	origin_tech = "combat=2;magnets=4"
	w_class = 5
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)

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
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "obj/item/gun.dmi"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
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
		select_fire(user)
		update_icon()
		return

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
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


/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
