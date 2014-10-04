/obj/item/weapon/gun/energy/laser
	name = "laser gun"
	desc = "a basic weapon designed kill with concentrated energy bolts"
	icon_state = "laser"
	item_state = "laser"
	fire_sound = 'sound/weapons/Laser.ogg'
	w_class = 3.0
	m_amt = 2000
	w_type = RECYK_ELECTRONIC
	origin_tech = "combat=3;magnets=2"
	projectile_type = "/obj/item/projectile/beam"

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	projectile_type = "/obj/item/projectile/beam/practice"
	clumsy_check = 0

/obj/item/weapon/gun/energy/laser/pistol
	name = "laser pistol"
	desc = "A laser pistol issued to high ranking members of a certain shadow corporation."
	icon_state = "xcomlaserpistol"
	projectile_type = /obj/item/projectile/beam
	charge_cost = 100 // holds less "ammo" then the rifle variant.

/obj/item/weapon/gun/energy/laser/rifle
	name = "laser rifle"
	desc = "A laser rifle issued to high ranking members of a certain shadow corporation."
	icon_state = "xcomlasergun"
	projectile_type = /obj/item/projectile/beam
	charge_cost = 50

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
	projectile_type = "/obj/item/projectile/beam/captain"


	New()
		..()
		processing_objects.Add(src)


	Destroy()
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



/*/obj/item/weapon/gun/energy/laser/cyborg/load_into_chamber()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(100)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0*/

/obj/item/weapon/gun/energy/laser/cyborg
	var/charge_tick = 0
	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()

	process() //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < 3) return 0
		charge_tick = 0

		if(!power_supply) return 0 //sanity
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(charge_cost) 		//Take power from the borg...
				power_supply.give(charge_cost)	//... to recharge the shot

		update_icon()
		return 1



/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = "/obj/item/projectile/beam/heavylaser"

	fire_delay = 2

	isHandgun()
		return 0

/obj/item/weapon/gun/energy/lasercannon/cyborg/load_into_chamber()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(250)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0

/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	fire_sound = 'sound/weapons/laser3.ogg'
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	projectile_type = "/obj/item/projectile/beam/xray"
	charge_cost = 50


/obj/item/weapon/gun/energy/plasma
	name = "plasma gun"
	desc = "A high-power plasma gun. You shouldn't ever see this."
	icon_state = "xray"
	fire_sound = 'sound/weapons/elecfire.ogg'
	origin_tech = "combat=5;materials=3;magnets=2"
	projectile_type = /obj/item/projectile/energy/plasma
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/pistol
	name = "plasma pistol"
	desc = "Plasma pistol that is given to members of an unknown shadow organization."
	icon_state = "alienpistol"
	projectile_type = /obj/item/projectile/energy/plasma/pistol
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/light
	name = "light plasma rifle"
	desc = "Light plasma rifle that is given to members of an unknown shadow organization."
	icon_state = "lightalienrifle"
	projectile_type = /obj/item/projectile/energy/plasma/light
	charge_cost = 100

/obj/item/weapon/gun/energy/plasma/rifle
	name = "plasma rifle"
	desc = "Plasma rifle that is given to members of an unknown shadow organization."
	icon_state = "alienrifle"
	projectile_type = /obj/item/projectile/energy/plasma/rifle
	charge_cost = 150

/obj/item/weapon/gun/energy/plasma/MP40k
	name = "Plasma MP40k"
	desc = "A plasma MP40k. Ich liebe den geruch von plasma am morgen."
	icon_state = "PlasMP"
	projectile_type = /obj/item/projectile/energy/plasma/MP40k
	charge_cost = 75

/obj/item/weapon/gun/energy/laser/LaserAK
	name = "Laser AK470"
	desc = "A laser AK. Death solves all problems -- No man, no problem."
	icon_state = "LaserAK"
	projectile_type = /obj/item/projectile/beam
	charge_cost = 75

////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "Standard issue weapon of the Imperial Guard"
	projectile_type = "/obj/item/projectile/beam/lastertag/blue"
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


	Destroy()
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
	projectile_type = "/obj/item/projectile/beam/lastertag/red"
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


	Destroy()
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