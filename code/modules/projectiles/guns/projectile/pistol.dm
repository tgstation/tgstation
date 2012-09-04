/obj/item/weapon/gun/projectile/silenced
	name = "Silenced Pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	w_class = 3.0
	max_shells = 12
	caliber = ".45"
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"



/obj/item/weapon/gun/projectile/deagle
	name = "Desert Eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon_state = "deagle"
	force = 14.0
	max_shells = 7
	caliber = ".50"
	ammo_type ="/obj/item/ammo_casing/a50"
	load_method = 2
	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a50/empty(src)
		update_icon()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return

/obj/item/weapon/gun/projectile/deagle/gold
	name = "Desert Eagle"
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/deagle/camo
	name = "Desert Eagle"
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/gyropistol
	name = "Gyrojet Pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	max_shells = 8
	caliber = "75"
	fire_sound = 'sound/effects/Explosion1.ogg'
	origin_tech = "combat=3"
	ammo_type = "/obj/item/ammo_casing/a75"
	load_method = 2
	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a75/empty(src)
		update_icon()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return

	update_icon()
		..()
		if(empty_mag)
			icon_state = "gyropistolloaded"
		else
			icon_state = "gyropistol"
		return