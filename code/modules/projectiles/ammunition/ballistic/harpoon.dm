/obj/item/ammo_casing/harpoon
	name = "harpoon"
	caliber = CALIBER_HARPOON
	icon_state = "magspear"
	base_icon_state = "magspear"
	projectile_type = /obj/projectile/bullet/harpoon
	newtonian_force = 1.5

/obj/item/ammo_casing/harpoon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless, TRUE)

/obj/item/ammo_casing/harpoon/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"
