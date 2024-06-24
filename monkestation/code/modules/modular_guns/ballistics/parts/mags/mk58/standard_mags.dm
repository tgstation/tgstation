/obj/item/attachment/mag/mk58
	name = "mk58 mag"
	icon = 'monkestation/code/modules/modular_guns/icons/mk58.dmi'
	attachment_icon = 'monkestation/code/modules/modular_guns/icons/mk58.dmi'
	attachment_rail = GUN_ATTACH_MK_58
	icon_state = "mag_4.35"

/obj/item/attachment/mag/mk58/m10mm
	name = "mk58 10mm mag"

	icon_state = "mag_4.35"
	attachment_icon_state = "well_pistol"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm

	fire_multipler = 1.2
	stability = 1.1
	noise_multiplier = 0.85

/obj/item/attachment/mag/mk58/m50
	name = "mk58 .50ae mag"

	icon_state = "mag_2.35"
	attachment_icon_state = "well_pistol"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m50

	fire_multipler = 0.5
	noise_multiplier = 1.3
	stability = 0.95
