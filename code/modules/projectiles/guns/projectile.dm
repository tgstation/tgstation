/obj/item/weapon/gun/projectile
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason"
	name = "projectile gun"
	icon_state = "pistol"
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000

	var/ammo_type = /obj/item/ammo_casing/c10mm
	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info
	var/obj/item/ammo_box/magazine/magazine
	var/obj/item/ammo_casing/chambered = null // The round (not bullet) that is in the chamber.


/obj/item/weapon/gun/projectile/New()
	..()
	magazine = new mag_type(src)
	chamber_round()
	update_icon()
	return

/obj/item/weapon/gun/projectile/process_chambered()
//	if(in_chamber)
//		return 1

	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	AC.loc = get_turf(src) //Eject casing onto ground.
	chambered = null
	chamber_round()
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.BB = null
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/proc/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
	return

/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, mag_type))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new magazine into \the [src]!</span>"
			chamber_round()
			A.update_icon()
			update_icon()
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0

/obj/item/weapon/gun/projectile/attack_self(mob/living/user as mob)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	update_icon()
	return


/obj/item/weapon/gun/projectile/examine()
	..()
	usr << "Has [get_ammo()] round\s remaining."
	return

/obj/item/weapon/gun/projectile/proc/get_ammo(var/countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets