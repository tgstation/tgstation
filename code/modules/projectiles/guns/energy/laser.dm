/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "A basic weapon designed kill with concentrated energy bolts."
	icon_state = "laser"
	item_state = "laser100"
	fire_sound = 'Laser.ogg'
	w_class = 3.0
	m_amt = 2000
	force = 7
	origin_tech = "combat=3;magnets=2"
	projectile_type = "/obj/item/projectile/beam"

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	projectile_type = "/obj/item/projectile/practice"


obj/item/weapon/gun/energy/laser/retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."


/obj/item/weapon/gun/energy/laser/captain
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	icon_state = "caplaser"
	item_state = "laser"
	force = 10
	origin_tech = null
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
		power_supply.give(100)
		update_icon()
		return 1



/obj/item/weapon/gun/energy/laser/cyborg/load_into_chamber()
	if(in_chamber)
		if(!istype(in_chamber, projectile_type))
			del(in_chamber)
			in_chamber = new projectile_type(src)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(100)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0



/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	item_state = "laser100"
	fire_sound = 'lasercannonfire.ogg'
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = "/obj/item/projectile/beam/heavylaser"


/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	fire_sound = 'laser3.ogg'
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	projectile_type = "/obj/item/projectile/beam/xray"
	charge_cost = 50


////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "Standard issue weapon of the Imperial Guard"
	projectile_type = "/obj/item/projectile/bluetag"
	origin_tech = "combat=1;magnets=2"
	var/charge_tick = 0

	special_check(var/mob/living/carbon/human/M)
		if(ishuman(M))
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				return 1
			M << "\red You need to be wearing your laser tag vest!"
		return 0

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



/obj/item/weapon/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "Standard issue weapon of the Imperial Guard"
	projectile_type = "/obj/item/projectile/redtag"
	origin_tech = "combat=1;magnets=2"
	var/charge_tick = 0

	special_check(var/mob/living/carbon/human/M)
		if(ishuman(M))
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				return 1
			M << "\red You need to be wearing your laser tag vest!"
		return 0

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