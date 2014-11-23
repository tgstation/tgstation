/obj/item/weapon/gun/projectile/automatic/suppressed
	name = "suppressed pistol"
	desc = "A small, quiet,  easily concealable handgun. Uses .45 rounds."
	icon_state = "suppressed_pistol"
	w_class = 3.0
	suppressed = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/sm45
	fire_sound = 'sound/weapons/Gunshot_silenced.ogg'

/obj/item/weapon/gun/projectile/automatic/suppressed/update_icon()
	..()
	icon_state = "[initial(icon_state)]"
	return


/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo."
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50


/obj/item/weapon/gun/projectile/automatic/deagle/afterattack()
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/automatic/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/automatic/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/Explosion1.ogg'
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/m75

/obj/item/weapon/gun/projectile/automatic/gyropistol/process_chamber(var/eject_casing = 0, var/empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/gyropistol/afterattack()
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol
	name = "\improper Stechkin pistol"
	desc = "A small, easily concealable handgun. Uses 10mm ammo and has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = 2
	suppressed = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m10mm

/obj/item/weapon/gun/projectile/automatic/pistol/attack_hand(mob/user as mob)
	if(loc == user)
		if(suppressed)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user << "<span class='notice'>You unscrew [suppressed] from [src].</span>"
			user.put_in_hands(suppressed)
			var/obj/item/weapon/suppressor/S = suppressed
			fire_sound = S.oldsound
			suppressed = 0
			w_class = 2
			update_icon()
			return
	..()


/obj/item/weapon/gun/projectile/automatic/pistol/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/suppressor))
		if(user.l_hand != src && user.r_hand != src)	//if we're not in his hands
			user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
			return
		user.drop_item()
		user << "<span class='notice'>You screw [I] onto [src].</span>"
		suppressed = I	//dodgy?
		var/obj/item/weapon/suppressor/S = I
		S.oldsound = fire_sound
		fire_sound = 'sound/weapons/Gunshot_silenced.ogg'
		w_class = 3
		I.loc = src		//put the suppressor into the gun
		update_icon()
		return
	..()

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][suppressed ? "-suppressor" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/suppressor
	name = "suppressor"
	desc = "A universal syndicate small-arms suppressor."
	icon = 'icons/obj/gun.dmi'
	icon_state = "suppressor"
	w_class = 2
	var/oldsound = 0 //Stores the true sound the gun made before it was suppressed