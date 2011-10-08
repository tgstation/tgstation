/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	icon_state = "laser"
	fire_sound = 'Laser.ogg'
	w_class = 3.0
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"
	projectile_type = "/obj/item/projectile/beam"




/obj/item/weapon/gun/energy/laser/captain
	icon_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = "combat=5;magnets=4"
	var/charge_tick = 0


	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(!charge_tick >= 5)	return 0
		charge_tick = 0
		if(!power_supply)	return 0
		power_supply.give(100)
		update_icon()
		return 1


/obj/item/weapon/gun/energy/laser/cyborg/load_into_chamber()
	if(in_chamber)	return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(40)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0



/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "A heavy-duty laser cannon."
	icon_state = "lasercannon"
	fire_sound = 'lasercannonfire.ogg'
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = "/obj/item/projectile/beam/heavylaser"
