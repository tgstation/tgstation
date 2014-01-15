/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "a basic weapon designed kill with concentrated energy bolts"
	icon_state = "laser"
	item_state = "laser"
	w_class = 3.0
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser)


/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0

obj/item/weapon/gun/energy/laser/retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."


/obj/item/weapon/gun/energy/laser/captain
	icon_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
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



/obj/item/weapon/gun/energy/laser/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return


/obj/item/weapon/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)

	attack_self(mob/living/user as mob)
		select_fire(user)
		update_icon()


/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	origin_tech = "combat=4;materials=3;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/heavy)


/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)


////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "Standard issue weapon of the Imperial Guard"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0
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
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0
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