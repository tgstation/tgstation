/obj/item/weapon/gun/projectile/automatic/pistol
	name = ".22 pistol"
	desc = "A small, easily concealable .22 pistol."
	icon_state = "pistol"
	w_class = 1
	origin_tech = "combat=2;materials=2;syndicate=2"
	fire_sound = 'sound/weapons/Gunshot_silenced.ogg'
	mag_type = /obj/item/ammo_box/magazine/m22
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	suppressed = 1
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol/m1911
	name = "M1911 pistol"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = 3
	fire_sound = 'sound/weapons/Gunshot.ogg'
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle
	name = "desert eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	fire_sound = 'sound/weapons/Gunshot.ogg'
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"
	fire_sound = 'sound/weapons/Gunshot.ogg'

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"
	fire_sound = 'sound/weapons/Gunshot.ogg'