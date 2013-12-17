/obj/item/weapon/gun/projectile/automatic/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	w_class = 3.0
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	ammo_type = /obj/item/ammo_casing/c45
	mag_type = /obj/item/ammo_box/magazine/sm45
	fire_sound = 'sound/weapons/Gunshot_silenced.ogg'

/obj/item/weapon/gun/projectile/automatic/silenced/update_icon()
	..()
	icon_state = "[initial(icon_state)]"
	return


/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon_state = "deagle"
	force = 14.0
	ammo_type = /obj/item/ammo_casing/a50
	mag_type = /obj/item/ammo_box/magazine/m50


/obj/item/weapon/gun/projectile/automatic/deagle/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
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
	ammo_type = /obj/item/ammo_casing/a75
	mag_type = /obj/item/ammo_box/magazine/m75

/obj/item/weapon/gun/projectile/automatic/gyropistol/New()
	..()
	update_icon()
	return


/obj/item/weapon/gun/projectile/automatic/gyropistol/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol
	name = "\improper Stechtkin pistol"
	desc = "A small, easily concealable gun. Uses 10mm rounds."
	icon_state = "pistol"
	w_class = 2
	silenced = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	mag_type = /obj/item/ammo_box/magazine/m10mm

/obj/item/weapon/gun/projectile/automatic/pistol/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(magazine)
		if(!chambered && !magazine.ammo_count())
			magazine.update_icon()
			magazine.loc = get_turf(src.loc)
			magazine = null
	return

/obj/item/weapon/gun/projectile/automatic/pistol/attack_hand(mob/user as mob)
	if(loc == user)
		if(silenced)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user << "<span class='notice'>You unscrew [silenced] from [src].</span>"
			user.put_in_hands(silenced)
			var/obj/item/weapon/silencer/S = silenced
			fire_sound = S.oldsound
			silenced = 0
			w_class = 2
			update_icon()
			return
	..()


/obj/item/weapon/gun/projectile/automatic/pistol/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/silencer))
		if(user.l_hand != src && user.r_hand != src)	//if we're not in his hands
			user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
			return
		user.drop_item()
		user << "<span class='notice'>You screw [I] onto [src].</span>"
		silenced = I	//dodgy?
		var/obj/item/weapon/silencer/S = I
		S.oldsound = fire_sound
		fire_sound = 'sound/weapons/Gunshot_silenced.ogg'
		w_class = 3
		I.loc = src		//put the silencer into the gun
		update_icon()
		return
	..()

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][silenced ? "-silencer" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/silencer
	name = "silencer"
	desc = "a silencer"
	icon = 'icons/obj/gun.dmi'
	icon_state = "silencer"
	w_class = 2
	var/oldsound = 0 //Stores the true sound the gun made before it was silenced