/obj/item/weapon/gun/projectile/automatic/pistol
	name = "pistol"
	desc = "A small, easily concealable handgun. Uses 10mm ammo and has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = 2
	suppressed = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = 1

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][suppressed ? "-suppressor" : ""][chambered ? "" : "-e"]"
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