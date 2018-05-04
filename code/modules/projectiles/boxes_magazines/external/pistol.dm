/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m45/fire
	name = "handgun magazine (.45 incendiary)"
	icon_state = "9x19pI"
	desc = "A handgun magazine. Loaded with incendiary rounds which ignite the target."
	ammo_type = /obj/item/ammo_casing/c45/inc

/obj/item/ammo_box/magazine/m45/hp
	name = "handgun magazine (.45 hollow-point)"
	icon_state = "9x19pH"
	desc = "A handgun magazine. Loaded with hollow-point rounds which are more effective against unarmored targets."
	ammo_type = /obj/item/ammo_casing/c45/hp

/obj/item/ammo_box/magazine/m45/ap
	name = "handgun magazine (.45 armor-piercing)"
	icon_state = "9x19pA"
	desc = "A handgun magazine. Loaded with armor-piercing rounds which are more effective against armored targets."
	ammo_type = /obj/item/ammo_casing/c45/ap

/obj/item/ammo_box/magazine/m1911
	name = "handgun magazine (.45)"
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/m1911/update_icon()
	..()
	icon_state = "45-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon()
	..()
	icon_state = "9x19p-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50AE
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1
