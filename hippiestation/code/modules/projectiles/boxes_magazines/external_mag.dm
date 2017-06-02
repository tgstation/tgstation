/obj/item/ammo_box/magazine/g17
	name = "Glock 17 magazine (9mm)"
	desc = "A gun magazine."
	icon = 'hippiestation/icons/obj/ammo/ammo.dmi'
	icon_state = "g17"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 14

/obj/item/ammo_box/magazine/g17/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[Ceiling(ammo_count(0)/14)*14]"

/obj/item/ammo_box/magazine/m12g //Instead of being a child it needs to be this way to make bulldog shotguns and other mag based weapons work.
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug/stunslug_hippie

/obj/item/ammo_box/magazine/sniper_rounds
	ammo_type = /obj/item/ammo_casing/point50/point50_hippie