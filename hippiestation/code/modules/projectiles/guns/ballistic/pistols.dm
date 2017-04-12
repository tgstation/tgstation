/obj/item/weapon/gun/ballistic/automatic/pistol/g17
	name = "Glock 17"
	desc = "A classic 9mm handgun with a large magazine capacity. Used by security teams everywhere."
	icon = 'hippiestation/icons/obj/guns/projectile.dmi'
	icon_state = "glock17"
	w_class = 2
	mag_type = /obj/item/ammo_box/magazine/g17
	flight_x_offset = 18
	fire_sound = list('hippiestation/sound/weapons/pistol_glock17_1.ogg','hippiestation/sound/weapons/pistol_glock17_2.ogg')

/obj/item/weapon/gun/ballistic/automatic/pistol/g17/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return
