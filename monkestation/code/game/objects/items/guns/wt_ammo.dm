/obj/item/ammo_box/magazine/wt550m9/wtrub
	name = "wt550 magazine (Rubber 4.6x30mm)"
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	icon_state = "46x30mmtR-20"
	base_icon_state = "46x30mmtR"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rub

/obj/item/ammo_box/magazine/wt550m9/wtic/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_casing/c46x30mm/rub
	name = "4.6x30mm rubber bullet casing"
	desc = "A 4.6x30mm rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/rub

/obj/projectile/bullet/c46x30mm/rub
	name = "4.6x30mm rubber bullet"
	damage = 4
	stamina = 35
	embedding = null
	sharpness = NONE

/obj/item/ammo_box/magazine/wt550m9/wtsalt
	name = "wt550 magazine (Saltshot 4.6x30mm)"
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	icon_state = "46x30mmtS-20"
	base_icon_state = "46x30mmtS"
	ammo_type = /obj/item/ammo_casing/c46x30mm/salt

/obj/item/ammo_box/magazine/wt550m9/wtic/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_casing/c46x30mm/salt
	name = "4.6x30mm saltshot bullet casing"
	desc = "A 4.6x30mm saltshot bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/salt

/obj/projectile/bullet/c46x30mm/salt
	name = "4.6x30mm saltshot bullet"
	damage = 0
	stamina = 30
	embedding = null
	sharpness = NONE

/obj/item/gun/ballistic/automatic/wt550/no_mag
	spawnwithmagazine = FALSE
