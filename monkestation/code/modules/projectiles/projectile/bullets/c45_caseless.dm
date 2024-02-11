/obj/item/ammo_casing/caseless/c45_caseless
	name = "caseless .45 bullet"
	desc = "A .45 bullet casing. This one is caseless!"
	caliber = CALIBER_45
	projectile_type = /obj/projectile/bullet/c45/caseless

/obj/projectile/bullet/c45/caseless
	damage = 26 //parent damage var is 30

/obj/item/ammo_box/c45/caseless
	name = "ammo box (caseless .45)"
	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "caseless_45box"
	ammo_type = /obj/item/ammo_casing/caseless/c45_caseless
	multiple_sprites = AMMO_BOX_FULL_EMPTY
